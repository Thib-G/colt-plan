<template>
  <div class="container">
    <h1>Projects list</h1>
    <b-table
      small hover
      :items="items"
      :fields="fields"
    >
      <template slot="projectDescr" slot-scope="data">
        <router-link :to="`/project/${data.item.id}`">{{ data.item.projectDescr }}</router-link>
      </template>
    </b-table>
  </div>
</template>

<script>
import TaskService from '@/services/task-service';

export default {
  data() {
    return {
      taskService: TaskService,
      items: [],
      fields: [
        {
          key: 'id',
          label: 'Nr',
          sortable: true,
        },
        {
          key: 'projectDescr',
          label: 'Description',
          sortable: true,
        },
        {
          key: 'startDate',
          label: 'Start date',
          formatter: x => x.toLocaleString(),
          sortable: true,
        },
        {
          key: 'projectLeader',
          label: 'Leader',
          formatter: x => x.name,
          sortable: true,
        },
      ],
    };
  },
  created() {
    this.taskService.getAllProjects().then((data) => {
      this.items = data;
    });
  },
  methods: {
    onRowClicked(item) {
      this.$router.push(`/project/${item.id}`);
    },
  },
};
</script>

