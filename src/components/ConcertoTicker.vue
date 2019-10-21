<template>
  <div class="concerto-ticker" :style="content.style" v-html="content.data"></div>
</template>

<script>
  /* eslint no-console: 0 */

  import utils from '../utils'

  export default {
    name: 'ConcertoTicker',
    props: {
      content: Object
    },

    mounted() {
      if (this.content && this.content.config && this.content.config['disable_text_autosize'] === '1') {
        // do not resize
      } else {
        let maxSize = (this.content && this.content.config && this.content.config['max_text_autosize'] ? this.content.config['max_text_autosize'] : 200)
        setTimeout(() => this.resize(maxSize), 1)
      }
    },

    methods: {
      resize(maxSize) {
        this.$el.style.width = 'unset'
        this.$el.style.height = 'unset'
        utils.setOptimalFontSize(this.$el.parentElement.offsetWidth, this.$el.parentElement.offsetHeight, this.$el, maxSize, 12)
        this.$el.style.width = null
        this.$el.style.height = null
      },
    }
  }
</script>

<style>
  .concerto-ticker {
/*    display: flex; // this makes it appear without the transition
    align-items: center;
    justify-content: left;
    width: 100%;
    height: 100%;
*/
    display: block;
    position: absolute;
    width: 100%;
    height: 100%; 
  }

  .concerto-ticker p {
    margin-top: 0;
    margin-bottom: 0;
  }
</style>
