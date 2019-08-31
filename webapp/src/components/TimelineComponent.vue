<template>
  <div>
    <svg
      :width="width + margin.left + margin.right"
      :height="height + margin.top + margin.bottom"
    >
      <g
        class="content"
        :transform="`translate(${margin.left}, ${margin.top})`"
      >
        <template v-for="(item, index) in items">
          <g
            class="pointer"
            :class="{ done: item.isFinished }"
            :transform="`translate(0, ${lineHeight * index})`"
            :key="item.id"
            @click="setDone(item)"
          >

            <g>
              <text
                class="task"
                :fill="scaleColor.fill(item.activityType)"
                :x="leftColumn - 2"
                :y="lineHeight - 10"
              >
                {{ item.orderNr }} {{ item.taskDescr }}
              </text>
            </g>
            <g :transform="`translate(${leftColumn}, 0)`">
              <rect
                class="task"
                x="0"
                y="0"
                :height="lineHeight - 1"
                :width="width - leftColumn"
              />
              <line
                class="callout"
                :x1="5"
                :y1="lineHeight / 2"
                :x2="margin.middle + scale.x(isTemplate ? (-item.yrBefore) : item.calculatedDate)"
                :y2="lineHeight / 2"
              />
              <circle
                class="milestone"
                r="5"
                :cx="margin.middle + scale.x(isTemplate ? (-item.yrBefore) : item.calculatedDate)"
                :cy="lineHeight / 2"
                :fill="scaleColor.fill(item.activityType)"
              >
                <title v-if="item.calculatedDate">{{ formatDate(item.calculatedDate) }}</title>
              </circle>
              <text
                v-if="item.calculatedDate && item.activityType != 'START'"
                class="dateText"
                :x="margin.left + 10 + scale.x(item.calculatedDate)"
                y="20"
              >
                {{ formatDate(item.calculatedDate) }}
              </text>
              <template v-if="item.finishedDate">
                <g :transform="`translate(
                  ${margin.middle + scale.x(item.finishedDate) - 15/2},
                  ${15/2}
                )`">
                  <font-awesome-icon
                    :icon="['fas', 'check']"
                    width="15"
                    height="15"
                    :style="{ 'color': scaleColor.fill(item.activityType) }"
                  />
                </g>
              </template>
              <text
                v-if="item.calculatedDate && item.activityType === 'START'"
                class="dateStart"
                :x="margin.left - 10 + scale.x(item.calculatedDate)"
                y="20"
              >
                {{ formatDate(item.calculatedDate) }}
              </text>
            </g>
          </g>
        </template>
        <g
          v-if="items.length > 0"
          :transform="`translate(${leftColumn + margin.middle}, 0)`"
        >
          <line
            class="today"
            :x1="scale.x(today)"
            :x2="scale.x(today)"
            :y1="0"
            :y2="height"
          >
            <title>{{ today.toLocaleString() }}</title>
          </line>
        </g>
      </g>
      <g :transform="`translate(${margin.left + margin.middle + leftColumn}, ${margin.top})`">
        <g class="gridlines" v-axis:x="{ 'fn': scale, 'height': height }"></g>
      </g>
      <g
        class="legend"
        :transform="`translate(
            ${(width + margin.left + margin.right - scaleColor.fill.domain().length * 50) / 2},
            ${margin.top + lineHeight * items.length}
          )`"
      >
        <template v-for="(activityType, index) in scaleColor.fill.domain()">
          <g :transform="`translate(${index * 50}, ${margin.bottom - 20})`" :key="index">
            <circle cx="5" cy="0" r="4" :fill="scaleColor.fill(activityType)" />
            <text x="12" y="4">{{ activityType }}</text>
          </g>
        </template>
      </g>
    </svg>
  </div>
</template>

<script>
import { DateTime } from 'luxon';

import d3 from '@/assets/d3';

export default {
  props: ['items', 'isTemplate', 'doneItems'],
  data() {
    return {
      lineHeight: 30,
      leftColumn: 300,
      width: 800,
      margin: {
        top: 40,
        bottom: 40,
        left: 20,
        right: 20,
        middle: 20,
      },
      today: DateTime.local().startOf('day'),
    };
  },
  computed: {
    height() {
      return this.lineHeight * this.items.length;
    },
    scale() {
      if (this.isTemplate) {
        const x = d3.scaleLinear()
          .rangeRound([0, this.width - this.leftColumn - this.margin.left - this.margin.right])
          .domain([-5, 0]);
        return { x };
      }
      const dates = this.items.map(item => item.calculatedDate);
      const dateMin = DateTime.min(...dates).startOf('year');
      const dateMax = DateTime.max(...dates).plus({ years: 1 }).startOf('year');
      const x = d3.scaleTime()
        .rangeRound([0, this.width - this.leftColumn - this.margin.left - this.margin.right])
        .domain([dateMin, dateMax]);
      return { x };
    },
    scaleColor() {
      const activityTypes = this.items.map(item => item.activityType);
      const fill = d3.scaleOrdinal(d3.schemeCategory10)
        .domain(activityTypes);
      return { fill };
    },
  },
  methods: {
    formatDate(dt) {
      return dt.toLocaleString();
    },
    setDone(item) {
      this.$emit('onSetDone', item);
    },
  },
  directives: {
    axis(el, binding) {
      const axis = binding.arg;
      const axisMethod = { x: 'axisTop' }[axis];
      const methodArg = binding.value.fn[axis];

      d3.select(el).call(d3[axisMethod](methodArg)
        .tickSize(-binding.value.height));
    },
  },
};
</script>

<style scoped>
  svg {
    font-size: 12pt;
  }
  g>g>rect.task {
    fill:lemonchiffon;
    opacity: 0;
    transition: opacity .5s;
  }
  g:hover>g>rect.task {
    opacity: 1;
  }
  g>g>text.dateText {
    fill:black;
    opacity: 0;
    transition: opacity .5s;
  }
  g>g>text.dateStart {
    fill: black;
    text-anchor: end;
  }
  g:hover>g>text.dateText {
    opacity: 1;
  }
  text.task {
    text-anchor: end;
  }
  .done text.task {
    text-decoration-line: line-through;
  }
  line.today {
    stroke: orangered;
    stroke-width: 1;
    opacity: .3;
  }
  g>g>line.callout {
    stroke: gray;
    stroke-width: 1;
    stroke-dasharray: 2, 2;
    opacity: 0;
    transition: opacity .5s;
  }
  g:hover>g>line.callout {
    opacity: 1;
  }
  g.done {
    opacity: .4;
  }

  .gridlines >>> .tick line {
    stroke: #bbb;
    stroke-dasharray: 2, 2;
  }
  .gridlines >>> path {
    display: none;
  }
  .gridlines >>> text {
    fill: #888;
  }
</style>
