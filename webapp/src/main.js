// Polyfills
import 'core-js/fn/promise';
import 'core-js/fn/number/is-nan';
import 'core-js/fn/math/trunc';
import 'core-js/fn/array/includes';
import 'core-js/fn/array/find-index';

// CSS imports (Bootstrap and BootstrapVue)
import 'bootstrap/dist/css/bootstrap.css';
import 'bootstrap-vue/dist/bootstrap-vue.css';

// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue';
import BootstrapVue from 'bootstrap-vue';

// font-awesome
import fontawesome from '@fortawesome/fontawesome';
import FontAwesomeIcon from '@fortawesome/vue-fontawesome';
import faCheck from '@fortawesome/fontawesome-free-solid/faCheck';

import '@/assets/style/app.css';

import App from './App';
import router from './router';

Vue.config.productionTip = false;
Vue.use(BootstrapVue);

// Use any icon from the Solid style
fontawesome.library.add(faCheck);
// Use the icon component anywhere in the app
Vue.component('font-awesome-icon', FontAwesomeIcon);

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  components: { App },
  template: '<App/>',
});
