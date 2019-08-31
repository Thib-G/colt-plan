import axios from 'axios';
import { DateTime } from 'luxon';

const GRAPHQL_URL = 'http://localhost:5000/graphql';

export default {
  projectTabIndex: 0,
  getTasksByTemplateId(templateIdParam) {
    const templateId = +templateIdParam;
    const query = `
      query taskQuery($templateId: Int)
      {
        allTasks(
          condition: {
            templateId: $templateId
          }
          orderBy: ORDER_NR_ASC
        ) {
          nodes {
            id: rowId
            templateId
            orderNr
            taskDescr
            yrBefore
            activityType
            resmgrId
          }
        }
      }
    `;
    const variables = { templateId };
    return axios.post(GRAPHQL_URL, { query, variables })
      .then(response => response.data.data.allTasks.nodes);
  },
  getAllProjects() {
    const query = `
      {
        allStartDates {
          nodes {
            id: rowId
            projectDescr
            startDate
            projectLeader: projectLeaderByProjectLeaderLogin {
              id: rowId
              login
              name
            }
          }
        }
      }
    `;
    return axios.post(GRAPHQL_URL, { query })
      .then(response => response.data.data.allStartDates.nodes
        .map(project => Object.assign({}, project,
          { startDate: DateTime.fromISO(project.startDate) })));
  },
  getTasksByProjectId(projectIdParam) {
    const projectId = +projectIdParam;
    const query = `
    query tasksByProjectId($projectId: Int)
    {
      allStartDates (
        condition: {
          rowId: $projectId
        }
      ) {
        nodes {
          id: rowId
          projectDescr
          startDate
          projectLeader: projectLeaderByProjectLeaderLogin {
            id: rowId
            login
            name
          }
          template: templateByTemplateId {
            id: rowId
            descr
            tasks: tasksByTemplateId {
              nodes {
                id: rowId
                orderNr
                taskDescr
                yrBefore
                activityType
              }
            }
          }
        }
      }
    }
    `;
    const variables = { projectId };
    return axios.post(GRAPHQL_URL, { query, variables })
      .then((response) => {
        const project = response.data.data.allStartDates.nodes[0];
        return Object.assign(
          {},
          project,
          { startDate: DateTime.fromISO(project.startDate) },
        );
      });
  },
  addFinishedTask(projectIdParam, taskIdParam, finishedDate = DateTime.local()) {
    const projectId = +projectIdParam;
    const taskId = +taskIdParam;
    const query = `
      mutation addFinishedTask($task: FinishedTaskInput!) {
        createFinishedTask(input: {
          finishedTask: $task
        }) 
        {
          finishedTask {
            id: rowId
            projectId
            taskId
            finishedDate
          }
        }
      }
    `;
    const variables = {
      task: {
        taskId,
        projectId,
        finishedDate: finishedDate.toISO(),
      },
    };
    return axios.post(GRAPHQL_URL, { query, variables })
      .then((response) => {
        // eslint-disable-next-line
        const finishedTask = response.data.data.createFinishedTask.finishedTask;
        return Object.assign(
          {},
          finishedTask,
          { finishedDate: DateTime.fromISO(finishedTask.finishedDate) },
        );
      });
  },
  removeFinishedTask(idParam) {
    const id = +idParam;
    const query = `
      mutation deleteFinishedTask($id: Int!) {
        deleteFinishedTaskByRowId(input: {
          rowId: $id
        }) 
        {
          finishedTask {
            id: rowId
            projectId
            taskId
            finishedDate
          }
        }
      }
    `;
    const variables = { id };
    return axios.post(GRAPHQL_URL, { query, variables })
      .then((response) => {
        const deletedTask = response.data.data.deleteFinishedTaskByRowId.finishedTask;
        return Object.assign(
          {},
          deletedTask,
          { finishedDate: DateTime.fromISO(deletedTask.finishedDate) },
        );
      });
  },
  getFinishedTasks(projectIdParam) {
    const projectId = +projectIdParam;
    const query = `
      query finishedTasksByProjectId($projectId: Int)
      {
        allFinishedTasks (
          condition: {
            projectId: $projectId
          }
        ) {
          nodes {
            id: rowId
            projectId
            taskId
            finishedDate
          }
        }
      }
    `;
    const variables = { projectId };
    return axios.post(GRAPHQL_URL, { query, variables })
      .then(response => response.data.data.allFinishedTasks.nodes
        .map(task => Object.assign(
          {},
          task,
          { finishedDate: DateTime.fromISO(task.finishedDate) },
        )));
  },
};
