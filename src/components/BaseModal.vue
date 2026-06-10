<script setup lang="ts">
import { useAttrs } from "vue";

defineOptions({
    inheritAttrs: false
});

const props = defineProps<{
    show: boolean;
    variant?: "default" | "min";
}>();

const emit = defineEmits<{
    close: [];
    overlayClick: [];
}>();

function handleOverlayClick() {
    emit("overlayClick");
}

const attrs = useAttrs();
</script>
<template>
    <Teleport to="body">
        <!-- v-if musi być TU, wewnątrz Teleport -->
        <div v-if="props.show" class="modal-overlay" @click.self="handleOverlayClick">
            <div class="modal" :class="{
                'modal--min': props.variant === 'min'
            }" v-bind="attrs">
                <slot />
            </div>
        </div>
    </Teleport>
</template>

<style scoped>
:global(:root) {
    --bg-modal: #ffffff;
    --text-modal: #333333;
    --shadow-modal: rgba(0, 0, 0, 0.15);
    --overlay-color: rgba(0, 0, 0, 0.45);
}

:global(html.dark) {
    --bg-modal: #1e1e1e;
    --text-modal: #e0e0e0;
    --shadow-modal: rgba(0, 0, 0, 0.5);
    --overlay-color: rgba(0, 0, 0, 0.65);
}

.modal-overlay {
    position: fixed;
    inset: 0;
    background: var(--overlay-color);

    display: flex;
    justify-content: center;
    align-items: center;

    z-index: 9999;
    transition: background 0.3s;
}

.modal {
    background: var(--bg-modal);
    color: var(--text-modal);
    border-radius: 8px;
    padding: 20px;
    min-width: 250px;
    max-width: 700px;
    box-shadow: 0 4px 12px var(--shadow-modal);
    transition: background-color 0.3s, color 0.3s, box-shadow 0.3s;
}

/* variants */
.modal--min {
    min-width: 100px;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
}
</style>