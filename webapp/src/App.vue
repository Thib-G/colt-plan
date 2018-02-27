<template>
  <div>
    <navbar-top />
    <div id="app">
      <router-view />
    </div>
  </div>
</template>

<script>
import NavbarTop from '@/components/NavbarTop';

export default {
  name: 'App',
  components: {
    'navbar-top': NavbarTop,
  },
};
</script>

<style>
#app {
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
