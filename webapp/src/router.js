import Vue from 'vue';
import Router from 'vue-router';
import TemplatePage from '@/pages/TemplatePage.vue';
import ProjectsPage from '@/pages/ProjectsPage.vue';
import ProjectPage from '@/pages/ProjectPage.vue';
import TestPage from '@/pages/TestPage.vue';

Vue.use(Router);

const appRouter = new Router({
  mode: 'history',
  routes: [
    {
      path: '/',
      redirect: '/projects',
    },
    {
      path: '/projects',
      name: 'ProjectsPage',
      component: ProjectsPage,
      meta: { title: 'Projects' },
    },
    {
      path: '/project/:id',
      name: 'ProjectPage',
      component: ProjectPage,
      meta: { title: 'Project' },
    },
    {
      path: '/template',
      name: 'TemplatePage',
      component: TemplatePage,
      meta: { title: 'Template' },
    },
    {
      path: '/test',
      name: 'TestPage',
      component: TestPage,
      meta: { title: 'Test page' },
    },
  ],
});

appRouter.beforeEach((to, from, next) => {
  const title = `Colt Viz - ${to.meta.title}${(to.params.id ? ` ${to.params.id}` : '')}`;
  document.title = title;
  next();
});

export default appRouter;
