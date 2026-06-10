use serde::{Deserialize, Serialize};
use std::fs;
use tauri::Manager;

#[derive(Serialize, Deserialize)]
pub struct Todo {
    pub id: u64,
    pub date: String,
    pub text: String,
}

#[derive(Serialize, Deserialize)]
pub struct DateItem {
    pub id: u64,
    pub text: String,
}

#[derive(Serialize, Deserialize)]
pub struct AppState {
    pub theme: String,
    pub todos: Vec<Todo>,
    pub dates: Vec<DateItem>,
}

#[tauri::command]
fn save_todos(
    app_handle: tauri::AppHandle,
    todos: Vec<Todo>,
    dates: Vec<DateItem>,
    theme: String,
) -> Result<(), String> {

    let state = AppState { todos, dates, theme };

    let json = serde_json::to_string_pretty(&state)
        .map_err(|e| e.to_string())?;

    // ✅ Tauri v2 proper app data directory
    let mut path = app_handle
        .path()
        .app_data_dir()
        .map_err(|e| e.to_string())?;

    // ensure folder exists
    std::fs::create_dir_all(&path)
        .map_err(|e| e.to_string())?;

    path.push("todo.json");

    fs::write(&path, json)
        .map_err(|e| e.to_string())?;

    Ok(())
}

#[tauri::command]
fn load_todos(app_handle: tauri::AppHandle) -> Result<AppState, String> {
    let mut path = app_handle
        .path()
        .app_data_dir()
        .map_err(|e| e.to_string())?;
    path.push("todo.json");

    if !path.exists() { return Ok(AppState { todos: Vec::new(), dates: Vec::new(), theme: "light".to_string() }); }
    let json = fs::read_to_string(&path)
        .map_err(|e| e.to_string())?;

    let state: AppState = serde_json::from_str(&json)
        .map_err(|e| e.to_string())?;

    Ok(state)
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .invoke_handler(tauri::generate_handler![save_todos, load_todos])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
