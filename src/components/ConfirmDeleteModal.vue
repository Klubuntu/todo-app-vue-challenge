<script setup lang="ts">
import BaseModal from "./BaseModal.vue";

const props = defineProps<{
    show: boolean;
    date: string;
}>();

const emit = defineEmits<{
    close: [];
    confirm: [];
}>();

function confirmDelete() {
    emit("confirm");
    emit("close");
}
</script>

<template>
  <BaseModal
    :show="props.show"
    @close="emit('close')"
    @overlay-click="emit('close')"
  >
    <h2>Delete Date</h2>

        <p>
            Do you want to delete the date
            <strong>{{ props.date }}</strong>?
        </p>

        <p>
            It will also delete all todos associated with this date.
        </p>

        <p>
            <strong>This is irreversible!</strong>
        </p>

        <div class="actions">
            <button class="cancel-btn" @click="emit('close')">
                Cancel
            </button>

            <button class="danger-btn" @click="confirmDelete">
                Delete
            </button>
        </div>
    </BaseModal>
</template>

<style scoped>
.actions {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    margin-top: 20px;
}

.cancel-btn {
    background: #ddd;
    color: #333;
    border: none;
    padding: 10px 16px;
    border-radius: 5px;
    cursor: pointer;
}

.danger-btn {
    background: #d9363e;
    color: white;
    border: none;
    padding: 10px 16px;
    border-radius: 5px;
    cursor: pointer;
}
</style>