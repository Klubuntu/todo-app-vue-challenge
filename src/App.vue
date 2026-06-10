<script setup lang="ts">
import { ref, onMounted, computed } from "vue";
import { invoke } from "@tauri-apps/api/core";
import { watch } from "vue";
import { Moon, Sun, Notebook, Trash2, CirclePlus } from "lucide-vue-next";
import DatePickerModal from "./components/DatePickerModal.vue";
import ConfirmDeleteModal from "./components/ConfirmDeleteModal.vue";

interface DateItem {
  id: number;
  text: string;
}

interface Todo {
  theme?: string;
  id: number;
  date: string;
  text: string;
}

const dates = ref<DateItem[]>([
  { id: 1, text: "2026-06-01" },
  { id: 2, text: "2026-06-02" },
  { id: 3, text: "2026-06-03" },
  { id: 4, text: "2026-06-04" },
]);

const todos = ref<Todo[]>([]);
const selectedDate = ref("");
const isDark = ref(false);
const sidebarWidth = ref(300);
const isResizing = ref(false);
function startResizing() { isResizing.value = true; window.addEventListener("mousemove", handleMouseMove); window.addEventListener("mouseup", stopResizing); }
function handleMouseMove(e: MouseEvent) { if (!isResizing.value) return; const newWidth = e.clientX; if (newWidth >= 200 && newWidth <= 700) { sidebarWidth.value = newWidth; } }
function stopResizing() { isResizing.value = false; window.removeEventListener("mousemove", handleMouseMove); window.removeEventListener("mouseup", stopResizing); }
const showDateModal = ref(false);
const showDeleteModal = ref(false);
const dateToDelete = ref("");
const dateIdToDelete = ref<number | null>(null);

/* -- SERVER FUNCTIONS -- */
async function saveToFile() {
  try {
    await invoke("save_todos", {
      todos: todos.value,
      dates: dates.value, 
      theme: isDark.value ? "dark" : "light"
    });
  } catch (err) {
    console.error("Failed to save todos:", err);
  }
}

async function loadTodos() {
  try {
    const result = await invoke<{
      theme?: string; todos: Todo[]; dates: DateItem[]
    }>("load_todos");
    todos.value = result.todos;
    dates.value = result.dates;
    if (result.theme) { isDark.value = result.theme === "dark"; applyTheme(); }
  } catch (error) {
    console.error("Failed to load todos:", error);
    await loadTodosDefault();
  }
}

async function loadTodosDefault() {
  try {
    const result = await invoke<Todo[]>("get_todos");
    todos.value = result;
  } catch (error) {
    console.error("Failed to load todos:", error);

    // fallback data
    todos.value = [
      { id: 1, date: "2026-06-01", text: "Learn Tauri" },
      { id: 2, date: "2026-06-02", text: "Build a Todo App" },
      { id: 3, date: "2026-06-03", text: "Enjoy coding!" },
      { id: 4, date: "2026-06-04", text: "Improve UI/UX" },
    ];
  }
}

/* ----------------------- */

/* --- MODAL FUNCTIONS --- */

function createTodoForDate(date?: string) {
  showDateModal.value = false;
  if (!date) return;

  selectedDate.value = date;

  const exists = dates.value.some(d => d.text === date);

  if (!exists) {
    dates.value.push({
      id: Date.now(),
      text: date,
    });

    dates.value.sort((a, b) =>
      a.text.localeCompare(b.text)
    );
  }

  const todoExists = todos.value.some(t => t.date === date);
  if (!todoExists) {
    todos.value.push({
      id: Date.now(),
      date: date,
      text: "",
    });
  }

  saveToFile();
}

function askDeleteDate(id: number) {
  const date = dates.value.find(d => d.id === id);

  if (!date) return;

  dateToDelete.value = date.text;
  dateIdToDelete.value = id;
  showDeleteModal.value = true;
}

function confirmDeleteDate() {
  if (dateIdToDelete.value === null) return;

  dates.value = dates.value.filter(
    d => d.id !== dateIdToDelete.value
  );

  todos.value = todos.value.filter(
    t => t.date !== dateToDelete.value
  );

  saveToFile();
}

/* ----------------------- */

/* --- OTHER FUNCTIONS --- */
function applyTheme() {
  const html = document.documentElement; if (isDark.value) { html.classList.add("dark"); } else { html.classList.remove("dark"); }
}
function switchTheme() {
  isDark.value = !isDark.value; applyTheme(); saveToFile();
}
function changeTodo(date: string) {
  selectedDate.value = date;
}


const filteredTodos = computed(() => {
  if (!selectedDate.value) {
    return todos.value;
  }

  return todos.value.filter(
    todo => todo.date === selectedDate.value
  );
});

watch(
  todos,
  () => {
    saveToFile();
  },
  { deep: true }
);

onMounted(async () => {
  await loadTodos();

  if (dates.value.length) {
    selectedDate.value = dates.value[0].text;
  }
});
</script>

<template>
  <main class="container">
    <div class="col-left" :style="{ width: sidebarWidth + 'px', flex: 'none' }">
      <header class="header">
        <h2>Todo List</h2>
        <Moon v-if="!isDark" @click="switchTheme" />
        <Sun v-else @click="switchTheme" />
        <button class="add-btn" @click="showDateModal = true">
          <CirclePlus :size="23" />
          <span>Add Todo</span>
        </button>

        <DatePickerModal :show="showDateModal" @close="createTodoForDate" />
      </header>
      <ul>
        <li v-for="date in dates" :key="date.id">
          <div class="date-row" :class="{ active: date.text === selectedDate }">
            <Notebook :size="40" />
            <div class="date-item" @click="changeTodo(date.text)">
              {{ date.text }}
            </div>

            <button class="delete-btn" @click="askDeleteDate(date.id)">
              <Trash2 :size="20" />
              <span>DEL</span>
            </button>
          </div>

        </li>
      </ul>
    </div>
    <div class="resize-handle" @mousedown="startResizing"></div>

    <div class="col-right">
      <ul>
        <li v-for="todo in filteredTodos" :key="todo.id">
          <div style="margin:5px 0;">
            <h2>{{ todo.date }}</h2>
            <textarea v-model="todo.text" class="todo-textarea"></textarea>
          </div>
        </li>
      </ul>
    </div>
    <ConfirmDeleteModal :show="showDeleteModal" :date="dateToDelete" @close="showDeleteModal = false"
      @confirm="confirmDeleteDate" />
  </main>
</template>

<style>
/* Zmienne dla motywu jasnego */
:root {
  font-family: 'Calibri', Tahoma, Geneva, Verdana, sans-serif;
  --bg-main: #eee;
  --bg-card: #fff;
  --bg-sidebar: #fff;
  --bg-content: #f9f9f9;
  --bg-row: #f0f0f0;
  --bg-row-active: #d0e6ff;
  --text-main: #333;
  --text-muted: #666;
  --border-color: #ccc;
  --primary-color: #4c82af;
  --primary-hover: #3b6b94;
  --shadow-color: rgba(0, 0, 0, 0.1);
}

/* Zmienne dla motywu ciemnego */
html.dark {
  --bg-main: #111112;
  --bg-card: #141414;
  --bg-sidebar: #181818;
  --bg-content: #141414;
  --bg-row: #2a2a2a;
  --bg-row-active: #243b55;
  --text-main: #e0e0e0;
  --text-muted: #aaa;
  --border-color: #444;
  --primary-color: #3772a1;
  --primary-hover: #4c82af;
  --shadow-color: rgba(0, 0, 0, 0.4);
}

body {
  margin: 0 auto;
  background: var(--bg-main);
  color: var(--text-main);
  transition: background 0.3s, color 0.3s;
}

header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 15px;
}

.theme-toggle {
  cursor: pointer;
  color: var(--text-main);
  transition: transform 0.2s;
}

.theme-toggle:hover {
  transform: scale(1.1);
}

.container {
  display: flex;
  height: 100vh;
}

ul {
  padding: 0;
}

li {
  margin: 5px 0;
  list-style: none;
}

.resize-handle {
  position: absolute;
  top: 0;
  right: 0;
  width: 6px;
  height: 100%;
  cursor: col-resize;
  z-index: 10;
  background: transparent;
  transition: background 0.2s;
}

.resize-handle:hover {
  background: var(--primary-color);
  opacity: 0.5;
}

.col-left {
  position: relative;
  position: relative;


  max-width: 700px;
  min-width: 200px;
  display: block;
  overflow-y: auto;
  flex: 1;
  background: var(--bg-sidebar);
  padding: 20px;
  box-shadow: 2px 0 10px var(--shadow-color);
  transition: background 0.3s, box-shadow 0.3s;
}

.col-right {
  flex: 1;
  background: var(--bg-content);
  padding: 20px;
  box-shadow: -2px 0 10px var(--shadow-color);
  transition: background 0.3s, box-shadow 0.3s;
}

.add-btn {
  display: flex;
  align-items: center;
  gap: 4px;
  background: var(--primary-color);
  color: white;
  border: none;
  padding: 10px 20px;
  cursor: pointer;
  border-radius: 4px;
  transition: background 0.2s;
}

.add-btn:hover {
  background: var(--primary-hover);
}

.todo-box {
  background: var(--bg-card);
  padding: 15px;
  border-radius: 6px;
  box-shadow: 0 2px 5px var(--shadow-color);
  transition: background 0.3s;
}

.todo-box h2 {
  margin-top: 0;
  color: var(--text-main);
}

.todo-textarea {
  width: calc(100% - 20px);
  height: calc(100vh - 180px);
  padding: 10px;
  background: var(--bg-sidebar);
  color: var(--text-main);
  border: 1px solid var(--border-color);
  border-radius: 4px;
  resize: none;
  font-size: 16px;
  transition: background 0.3s, border-color 0.3s, color 0.3s;
}

.todo-textarea:focus {
  outline: none;
  border-color: var(--primary-color);
}

.date-item {
  width: 100%;
  padding: 10px;
  margin: 5px 0;
  cursor: pointer;
  font-weight: 500;
  color: var(--text-main);
}

.icon-notebook {
  color: var(--text-muted);
}

.date-row {
  position: relative;
  padding: 3px 10px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--bg-row);
  border-radius: 6px;
  transition: background 0.3s;
}

.date-row.active {
  background: var(--bg-row-active);
  border-left: 2.5px solid var(--primary-color);
  border-right: 2.5px solid var(--primary-color);
}

.delete-btn {
  display: flex;
  align-items: center;
  gap: 4px;
  margin-left: 10px;
  background: #ff4d4f;
  color: white;
  border: none;
  padding: 6px 10px;
  cursor: pointer;
  border-radius: 4px;
  transition: background 0.2s;
}

.delete-btn:hover {
  background: #d9363e;
}
</style>