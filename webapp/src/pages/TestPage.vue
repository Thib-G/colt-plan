<template>
  <div>
    <h1>Test page</h1>
    <div><button @click="clicked = true">Load component</button></div>
    <async-component v-if="clicked" />
  </div>
</template>

<script>
import axios from 'axios';

export default {
  data() {
    return {
      clicked: false,
    };
  },
  components: {
    'async-component': () => axios.post('http://localhost:5000/graphql', {
      query: `
      {
        asyncComponentByRowId(rowId: 1) {
          component
          content
        }
      }
    `,
    }).then((response) => {
      const comp = response.data.data.asyncComponentByRowId.content;
      // eslint-disable-next-line
      return eval(`(${comp})`);
    }),
  },
};
</script>
