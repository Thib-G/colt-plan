<template>
  <div class="container">
    <template v-if="project.id">
      <b-card
        :header="project.template.descr"
        :title="project.projectDescr"
        :sub-title="project.projectLeader.name"
      >
        <p class="card-text">Start date: {{ project.startDate.toLocaleString() }}</p>
      </b-card>
      <br />
    </template>
    <b-tabs nav-class="justify-content-center" v-model="taskService.projectTabIndex">
      <b-tab title="Timeline">
        <div>
          <timeline-component
            v-if="items.length > 0"
            :items="items"
            :doneItems="doneItems"
            @onSetDone="setDone"
          />
        </div>
      </b-tab>
      <b-tab title="Table">
        <div>
          <b-table
            small hover
            class="pointer-table"
            :items="tableItems"
            :fields="fields"
            @row-clicked="setDoneRow"
          >
            <template slot="finishedDate" slot-scope="data">
              <transition>
                <span v-if="data.item.finishedDate">
                  {{ data.item.finishedDate.toLocaleString() }}
                </span>
                <span v-else>
                  <item-date-button-component :item="data.item" @onSetDone="setDone" />
                </span>
              </transition>
            </template>
          </b-table>
        </div>
      </b-tab>
    </b-tabs>
  </div>
</template>

<script>
import { DateTime } from 'luxon';

import TaskService from '@/services/task-service';
import TimelineComponent from '@/components/TimelineComponent.vue';
import ItemDateButtonComponent from '@/components/ItemDateButtonComponent.vue';

export default {
  data() {
    return {
      newDate: null,
      dateTime: DateTime,
      taskService: TaskService,
      projectId: this.$route.params.id,
      project: {},
      finishedTasks: [],
      fields: [
        {
          key: 'orderNr',
          sortable: true,
        },
        {
          key: 'taskDescr',
          sortable: true,
        },
        {
          key: 'yrBefore',
          sortable: true,
        },
        {
          key: 'activityType',
          sortable: true,
        },
        {
          key: 'calculatedDate',
          sortable: true,
          formatter: dt => dt.toLocaleString(),
        },
        {
          key: 'finishedDate',
          sortable: true,
          formatter: dt => (dt ? dt.toLocaleString() : ''),
        },
      ],
    };
  },
  created() {
    this.taskService.getTasksByProjectId(this.projectId).then((data) => {
      this.project = data;
    });
    this.taskService.getFinishedTasks(this.projectId).then((data) => {
      this.finishedTasks = data;
    });
  },
  computed: {
    items() {
      if (!this.project.template) {
        return [];
      }
      const items = this.project.template.tasks.nodes;
      return items.map(item => Object.assign({}, item, {
        calculatedDate: this.project.startDate.minus({
          years: item.yrBefore,
        }),
        isFinished: this.finishedTaskIds.includes(item.id),
        finishedDate: this.finishedTaskIds.includes(item.id)
          ? this.finishedTasks.find(t => t.taskId === item.id).finishedDate
          : null,
      }));
    },
    tableItems() {
      return this.items.map(item => Object.assign({}, item, {
        _rowVariant: item.isFinished ? 'success' : '',
      }));
    },
    finishedTaskIds() {
      return this.finishedTasks.map(task => task.taskId);
    },
    doneItems() {
      return this.items.filter(item => this.finishedTaskIds.includes(item.id));
    },
  },
  methods: {
    setDone(item, newDate = DateTime.local()) {
      if (item.isFinished) {
        const { id } = this.finishedTasks.find(task => task.taskId === item.id);
        this.taskService.removeFinishedTask(id).then((data) => {
          const index = this.finishedTasks.findIndex(
            task => task.id === data.id,
          );
          this.finishedTasks.splice(index, 1);
        });
      } else {
        this.taskService
          .addFinishedTask(this.projectId, item.id, newDate)
          .then((data) => {
            this.finishedTasks.push(data);
          });
      }
    },
    setDoneRow(item) {
      this.setDone(item);
    },
  },
  components: {
    'timeline-component': TimelineComponent,
    'item-date-button-component': ItemDateButtonComponent,
  },
};
</script>
