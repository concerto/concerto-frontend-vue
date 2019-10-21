<template>
  <div class="concerto-screen" :class="{debug: debug, preview: screen.isPreview}">
    <div v-if="debug && setup" class="debug-screen">Screen {{setup.id}} - {{setup.name}}</div>
    <div v-if="setup && setup.template" :id="templateElementId" class="concerto-template" :style="backgroundImage">
      <div v-if="debug" class="debug-template">Template {{setup.template.id}} - {{setup.template.name}}</div>
      <div v-for="position in setup.template.positions" :key="position.id" class="concerto-position" :id="positionElementId(position)" :style="positionStyle(position)">
        <div v-if="debug" class="debug-position" :title="positionStyle(position)">Position {{position.id}}</div>
        <concerto-field :screen-id="setup.id" :field="fieldInfo(position)" :base-url="screen.baseUrl" :timezone="setup.time_zone" :locale="setup.locale" :debug="debug" :frontend-key="setupKey" @frontend-key-changed="frontendKeyChanged">
        </concerto-field>
      </div>
    </div>
    <div v-if="debug && status" class="debug-screen-status">
      <div>{{status}}</div>
      <small>(retrying every 15 seconds)</small>
    </div>
  </div>
</template>

<script>
  /* eslint no-console: 0 */

  import axios from 'axios'
  import utils from '../utils'
  import ConcertoField from './ConcertoField.vue'

  export default {
    name: 'ConcertoScreen',
    components: {
      ConcertoField
    },
    data: function() {
      return {
        setup: null,
        setupKey: null,
        status: null
      }
    },
    props: {
      debug: Boolean,
      screen: Object
    },
    computed: {
      backgroundImage: function () {
        let style = ''
        if (this.setup && this.setup.template && this.setup.template.path) {
          let url = utils.prefixWithBase(this.setup.template.path, this.screen.baseUrl)
          style = "background-image: url('" + url + "');"
        }
        return style
      },
      templateElementId: function () {
        return 'template_' + this.setup.template.id
      },
    },
    created() {
      // trigger an event on the fields every second so they can update their debug duration label
      setInterval(() => {
        this.$el.querySelectorAll('.concerto-field').forEach((el) => {
          let ev = new Event('concertotick')
          el.dispatchEvent(ev)
        })
      }, 1000)
    },

    mounted() {
      this.fetchSetup()
    },

    methods: {
      fieldInfo(position) {
        let field = {
          style: position.style
        }
        Object.keys(position.field).forEach(function(key) {
          field[key] = position.field[key];
        });

        return field
      },

      fetchSetup() {
        this.status = "fetching screen configuration..."
        // send the "screen's" resolution
        let width = this.$el.clientWidth;
        let height = this.$el.clientHeight;
        let url = this.screen.baseUrl + '/frontend/' + this.screen.id + '/setup.json?width=' + width + '&height=' + height
        return axios.get(url)
          .then((response) => {
            this.setup = response.data
            this.setupKey = response.headers['x-concerto-frontend-setup-key']
            this.status = null
            // force the observer to resolve
            // console.debug('data', JSON.parse(JSON.stringify(this.setup)), 'key', this.setupKey)

            /* load the css if any */
            if (this.setup.template.css_path && this.setup.template.css_path != "") {
              let css_link = document.createElement("link");
              css_link.type = "text/css";
              css_link.rel = "stylesheet";
              css_link.href = utils.prefixWithBase(this.setup.template.css_path, this.screen.baseUrl);
              document.head.appendChild(css_link);
            }
          })
          .catch((error) => {
            this.status = 'An error has ocurred - ' + error.message
            console.error(this.status)
            // try again in 15 seconds, via event loop so we dont nest calls
            setTimeout(this.fetchSetup, 15 * 1000)
          });
      },
      frontendKeyChanged() {
        console.debug('got notified that the frontend key has changed!')
        document.location.reload();
      },
      positionElementId: function (position) {
        return 'position_' + position.id
      },
      positionStyle: function(position) {
        let style = "left: " + (position.left * 100).toFixed(2) + "%; " +
          "top: " + (position.top * 100).toFixed(2) + "%; " + 
          "width: " + ((position.right - position.left) * 100).toFixed(2) + "%; " + 
          "height: " + ((position.bottom - position.top) * 100).toFixed(2) + "%;";
        return style;
      },
    }
  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style>
  .debug-screen, .debug-screen-status, .debug-template, .debug-position, .debug-field, .debug-field-status, .debug-field-duration {
    position: absolute;
    font-family: 'Franklin Gothic Medium', 'Arial Narrow', Arial, sans-serif;
    top: 0;
    right: 0;
    font-size: .6em;
    padding: .25em 1em;
    z-index: 1000;
    background-color: lightgray;
    opacity: .5;
    display: inline;
    font-weight: bold;
  }
  .debug-screen, .debug-position {
    left: 0;
    right: unset;
    border-bottom-right-radius: .5em;
  }
  .debug-field, .debug-template {
    border-bottom-left-radius: .5em;
  }
  .debug-field-duration {
    left: unset;
    top: unset;
    bottom: 0;
    right: 0;
    display: block;
    overflow: auto;
    border-top-left-radius: .5em;
  }
  .debug-field-status  {
    left: 0;
    top: unset;
    bottom: 0;
    right: unset;
    display: block;
    overflow: auto;
    border-top-right-radius: .5em;
  }
  .debug-screen-status {
    padding: 0;
    font-size:2em;
    opacity: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 100%;
    width: 100%;
    background-color: black;
    color: #222;
  }
  .debug-screen-status small {
    font-size: .5em;
    font-style: italic;
  }
  div[class^="debug-"]:hover {
    opacity: 1;
    z-index: 2000;
  }

  .concerto-screen {
    display: block;
    position: relative;
    width: 100%;
    height: 100%;
    cursor: none;
    overflow: hidden; /* no scrollbars */
  }
  .concerto-screen.preview, .concerto-screen.debug {
    cursor: auto;
  }
  .concerto-position {
    position: absolute;
    overflow: hidden;
  }
  .debug .concerto-position {
    border: dashed 1px gray;
  }
  .concerto-template {
    width: 100%;
    height: 100%;
    background-size: 100% 100%;
    background-repeat: no-repeat;
  }
</style>
