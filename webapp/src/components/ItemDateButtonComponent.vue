<template>
  <div class="finished-date-picker">
    <form @submit.prevent="setDone" @click.stop>
      <div class="input-group input-group-sm">
        <flat-pickr
          v-model="newDate"
          :config="config"
        />
        <div class="input-group-append">
          <input class="btn btn-outline-primary" type="submit" value="Set" :disabled="!newDate" />
        </div>
      </div>
    </form>
  </div>
</template>

<script>
import flatPickr from 'vue-flatpickr-component';
import 'flatpickr/dist/flatpickr.css';
import { DateTime } from 'luxon';

export default {
  props: ['item'],
  data() {
    return {
      isMounted: false,
      newDate: null,
      config: {
        wrap: true, // set wrap to true only when using 'input-group'
        altFormat: 'd/m/Y',
        altInput: true,
      },
    };
  },
  methods: {
    setDone() {
      if (this.newDate) {
        this.$emit('onSetDone', this.item, DateTime.fromISO(this.newDate));
      }
    },
  },
  components: {
    'flat-pickr': flatPickr,
  },
};
</script>

<style scoped>
  .finished-date-picker {
    width: 140px;
  }
</style>

