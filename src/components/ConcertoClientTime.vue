<template>
  <div class="concerto-client-time" v-html="datetime"></div>
</template>

<script>
  /* eslint no-console: 0 */

  import utils from '../utils'
  import moment from 'moment'
  import momentTimezone from 'moment-timezone'

  export default {
    name: 'ConcertoClientTime',
    data: function() {
      return {
        datetime: String
      }
    },
    props: {
      content: Object
    },

    mounted() {
      this.formatted()
    },

    methods: {
      resize(maxSize) {
        this.$el.style.width = 'unset'
        this.$el.style.height = 'unset'
        utils.setOptimalFontSize(this.$el.parentElement.offsetWidth, this.$el.parentElement.offsetHeight, this.$el, maxSize, 12)
        this.$el.style.width='100%'
        this.$el.style.height='100%'
      },

      formatted() {
        let tz = this.content.timezone
        let format = this.content.config["time_format"] || "MM/DD/YY <br/> hh:mm A"
        let now = tz ? moment().tz(tz) : moment()
        let locale = this.content.locale
        now = locale ? now.locale(locale) : now
        this.datetime = now.format(format)

        // place in the event loop so the value can get rendered in the element before we resize it
        if (this.content && this.content.config && this.content.config['disable_text_autosize'] === '1') {
          // do not resize
        } else {
          let maxSize = (this.content && this.content.config && this.content.config['max_text_autosize'] ? this.content.config['max_text_autosize'] : 200)
          setTimeout(() => this.resize(maxSize), 1)
        }
      }
    }
  }
</script>

<style>
  .concerto-client-time {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 100%;
  }

  .concerto-client-time * {
    margin: 0;
  }
</style>

