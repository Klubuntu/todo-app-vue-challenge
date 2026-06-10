<script setup lang="ts">
import { ref, watch } from "vue";
import { Calendar } from "lucide-vue-next";
import BaseModal from "./BaseModal.vue";

const props = defineProps<{
    show: boolean;
}>();

const emit = defineEmits<{
    close: [string?];
}>();

// Initialize with current date (YYYY-MM-DD)
const defaultDate = new Date().toISOString().split("T")[0];
const selectedDate = ref(defaultDate);

// Reference to the actual date input
const dateInputRef = ref<HTMLInputElement | null>(null);

/* Modal reset after reopen */
watch(
    () => props.show,
    (isOpen) => {
        if (isOpen) {
            selectedDate.value = defaultDate;
        }
    }
);

function cancel() {
    selectedDate.value = defaultDate;
    emit("close");
}

function create() {
    if (!selectedDate.value) return;
    emit("close", selectedDate.value);
}

function openPicker() {
    // showPicker() is supported in modern browsers for input[type="date"]
    if (dateInputRef.value) {
        dateInputRef.value.showPicker();
    }
}
</script>

<template>
    <BaseModal variant="min" :show="props.show" @overlay-click="create" @close="cancel">
        <h2>Create Todo</h2>

        <div class="date-wrapper">
            <Calendar class="icon" @click="openPicker" :size="18" />

            <input type="date" v-model="selectedDate" @click="openPicker" class="date-input" />

            <input ref="hidden" type="text" class="hidden-date" />
        </div>

        <div class="actions">
            <button class="cancel-btn" @click="cancel">
                Cancel
            </button>

            <button class="create-btn" @click="create">
                Create
            </button>
        </div>
    </BaseModal>
</template>

<style scoped>
/* Definiowanie zmiennych globalnie wewnątrz scoped za pomocą :global */
:global(:root) {
  --bg-input: #fff;
  --text-input: #333;
  --border-input: #ccc;
  --icon-color: #666;
  --color-scheme: light;
  
  --bg-date-btn: #f0f0f0;
  --text-date-btn: #333;
  --bg-date-active: #007bff;
  --text-date-active: #fff;
  
  --bg-cancel: #ddd;
  --text-cancel: #333;
  --bg-cancel-hover: #ccc;
  
  --bg-create: #28a745;
  --text-create: #fff;
  --bg-create-hover: #218838;
}

:global(html.dark) {
  --bg-input: #2a2a2a;
  --text-input: #e0e0e0;
  --border-input: #444;
  --icon-color: #aaa;
  --color-scheme: dark;
  
  --bg-date-btn: #2a2a2a;
  --text-date-btn: #e0e0e0;
  --bg-date-active: #1a73e8;
  --text-date-active: #fff;
  
  --bg-cancel: #444;
  --text-cancel: #e0e0e0;
  --bg-cancel-hover: #555;
  
  --bg-create: #1e7e34;
  --text-create: #fff;
  --bg-create-hover: #28a745;
}

h2 {
    color: var(--text-input);
    margin-top: 0;
}

.hidden-date {
    display: none;
    position: absolute;
    opacity: 0;
    pointer-events: none;
}

.date-wrapper {
    position: relative;
    display: flex;
    align-items: center;
}

.icon {
    position: absolute;
    left: 10px;
    top: 9px;
    pointer-events: none;
    color: var(--icon-color);
    transition: color 0.3s;
}

.date-input {
    width: 130px;
    padding: 8px;
    padding-left: 35px;
    margin-bottom: 16px;
    background-color: var(--bg-input);
    color: var(--text-input);
    border: 1px solid var(--border-input);
    border-radius: 4px;
    color-scheme: var(--color-scheme); /* Magiczna linijka dla ciemnego kalendarza */
    transition: background-color 0.3s, color 0.3s, border-color 0.3s;
}

.date-input:focus {
    outline: none;
    border-color: var(--bg-date-active);
}

.date-list {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-bottom: 20px;
}

.date-btn {
    padding: 6px 12px;
    background-color: var(--bg-date-btn);
    color: var(--text-date-btn);
    border: 1px solid var(--border-input);
    border-radius: 4px;
    cursor: pointer;
    transition: all 0.3s;
}

.date-btn.active {
    background-color: var(--bg-date-active);
    color: var(--text-date-active);
    border-color: var(--bg-date-active);
}

.cancel-btn {
    background: var(--bg-cancel);
    color: var(--text-cancel);
    border: none;
    padding: 10px 16px;
    border-radius: 5px;
    cursor: pointer;
    transition: background 0.2s, color 0.3s;
}

.cancel-btn:hover {
    background: var(--bg-cancel-hover);
}

.create-btn {
    background-color: var(--bg-create);
    color: var(--text-create);
    border: none;
    border-radius: 5px;
    padding: 10px 16px;
    cursor: pointer;
    transition: background-color 0.2s;
}

.create-btn:hover {
    background-color: var(--bg-create-hover);
}

.actions {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
}
</style>