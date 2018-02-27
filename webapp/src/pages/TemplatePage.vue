<template>
  <div>
    <h1>Template page</h1>
    <div>
      <timeline-component
        v-if="items.length > 0"
        :items="items"
        :is-template="true"
      />
    </div>
    <b-table small striped hover :items="items"></b-table>
  </div>
</template>

<script>
import TaskService from '@/services/task-service';
import TimelineComponent from '@/components/TimelineComponent';

export default {
  data() {
    return {
      taskService: TaskService,
      items: [],
    };
  },
  created() {
    this.taskService.getTasksByTemplateId(1).then((data) => {
      this.items = data;
    });
  },
  components: {
    'timeline-component': TimelineComponent,
  },
};
</script>
