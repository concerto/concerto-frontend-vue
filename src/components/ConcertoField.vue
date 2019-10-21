<template>
  <div class="concerto-field"
    :field-id="field.id"
    :field-name="field.name"
    @click="forceNextContent"
    @concertotick="concertoTicked"
  >
    <div v-if="debug" class="debug-field" :title="debugFieldTitle">Field {{field.id }} - {{field.name}}</div>
      <transition name="custom-classes-transition" :enter-active-class="transitionIn" :leave-active-class="transitionOut">
        <component v-for="content in currentContent" :key="content.contentId" v-bind:is="contentType" :content="content" :style="field.style" ></component>
      </transition>
    <div v-if="debug" class="debug-field-status">{{status}}</div>
    <div v-if="debug" class="debug-field-duration">{{ inInfo }}{{duration}}{{ outInfo }}</div>
  </div>
</template>

<script>
  /* eslint no-console: 0 */

  import axios from 'axios'
  import utils from '../utils'

  import ConcertoClientTime from "./ConcertoClientTime"
  import ConcertoEmpty from "./ConcertoEmpty"
  import ConcertoGraphic from "./ConcertoGraphic"
  import ConcertoHtmlText from "./ConcertoHtmlText"
  import ConcertoIframe from "./ConcertoIframe"
  import ConcertoRemoteVideo from "./ConcertoRemoteVideo"
  import ConcertoTicker from "./ConcertoTicker"

  export default {
    name: 'ConcertoField',
    props: {
      baseUrl: String,
      debug: Boolean,
      field: Object,
      frontendKey: String,
      locale: String,
      screenId: Number,
      timezone: String
    },
    data: function() {
      return {
        contentQueue: [],
        contentErrorCount: 0,
        contentType: null,
        currentContent: null,
        debouncedScheduleNextContent: null,
        lastUpdated: 0,
        status: ''
      }
    },
    components: {
      // the "canned" content
      ConcertoClientTime,
      ConcertoEmpty,
      ConcertoGraphic,
      ConcertoHtmlText,
      ConcertoIframe,
      ConcertoRemoteVideo,
      ConcertoTicker,
    },
    computed: {
      debugFieldTitle() {
        let info = []
        if (this.field) {
          if (this.field.style) {
            info.push('style: ' + this.field.style)
          }
          Object.keys(this.field.config).forEach(key => info.push(key + ': ' + this.field.config[key]))
        }
        return info.join(' \n ');
      },
      clearContentWhenEmpty() {
        // find out if this field should clear the last content when it is empty (default to true)
        let clearContent = this.field.config['screens_clear_last_content']
        if (clearContent == null || typeof clearContent == 'undefined') {
          clearContent = true
        }
        return clearContent
      },
      duration: function() {
        if (this.currentContent && this.currentContent.length !== 0) {
          return this.currentContent[0].duration
        }
        return ''
      },
      emptyContent: function() {
        return {
          duration: 10,
          id: Date.now(),
          name: 'Empty Content - Waiting',
          type: 'Empty',
          render_details: {}
        }
      },
      inInfo() {
        let info = ''
        if (this.field && this.field.config && this.field.config.entry_transition)
        {
          info = this.transitionIn + ' - '
        }
        return info
      },
      outInfo() {
        let info = ''
        if (this.field && this.field.config && this.field.config.exit_transition) {
          info = ' - ' + this.transitionOut
        }
        return info
      },
      suppressRepeatingContent() {
        // find out if we should display repeat content (default to false)
        let repeatContent = this.field.config['repeat_content'] && this.field.config['repeat_content'] === 'Reload'
        return !repeatContent
      },
      transitionIn: function () {
        // default to fade in
        let transition = 'animated fadeIn'
        // map old settings to new settings

        if (this.field.config && this.field.config.entry_transition) {
          switch (this.field.config.entry_transition) {
            case 'fade-in-animation':
              transition = 'animated fadeIn'
              break
            case 'scale-up-animation':
              transition = 'animated zoomIn'
              break
            case 'slide-left-animation':
            case 'slide-from-right-animation':
              transition = 'animated slideInRight'
              break
            case 'slide-right-animation':
            case 'slide-from-left-animation':
              transition = 'animated slideInLeft'
              break
            case 'slide-down-animation':
              transition = 'animated slideInDown'
              break
            case 'slide-up-animation':
              transition = 'animated slideInUp'
              break
            default:
              transition = 'animated ' + this.field.config.entry_transition
              break
          }
        }
        return transition
      },
      transitionOut: function () {
        // default to fade out
        let transition = 'animated fadeOut'
        // map old settings to new settings
        if (this.field.config && this.field.config.exit_transition) {
          switch (this.field.config.exit_transition) {
            case 'fade-out-animation':
              transition = 'animated fadeOut'
              break
            case 'scale-down-animation':
              transition = 'animated zoomOut'
              break
            case 'slide-left-animation':
            case 'slide-from-right-animation':
              transition = 'animated slideOutLeft'
              break
            case 'slide-right-animation':
            case 'slide-from-left-animation':
              transition = 'animated slideOutRight'
              break
            case 'slide-up-animation':
              transition = 'animated slideOutUp'
              break
            case 'slide-down-animation':
              transition = 'animated slideOutDown'
              break
            default:
              transition = 'animated ' + this.field.config.exit_transition
              break
          }
        }
        return transition
      }
    },
    mounted: function() {
      this.fetchContent()
      //this.loadNextContent()
    },
    methods: {
      concertoTicked() {
        if (this.debug) {
          this.decrementDuration()
        }
      },

      decrementDuration() {
        if (this.currentContent && this.currentContent.length > 0 && this.currentContent[0].duration > 0) {
          this.currentContent[0].duration--
        }
      },

      // allows user to click through content
      forceNextContent() {
        if (this.debouncedScheduleNextContent) {
          this.debouncedScheduleNextContent.flush()
        } else {
          this.scheduleNextContent(1)
        }
      },

      // check for frontend key mismatch (which simply means the server wants us to reload the screen)
      // but we will delegate that to the screen component
      isSameFrontendKey(key) {
        if (this.frontendKey && key && key !== this.frontendKey) {
          console.debug('different frontend-key detected')
          this.$emit('frontend-key-changed')
          return false
        }
        return true
      },

      fetchContent() {
        // console.debug(Date(), this.field.id, this.field.name, 'fetching content')
        this.status = 'fetching content'
        // send the field's container's dimensions to the server just in case it wants to use them
        let width = this.$el.parentElement.clientWidth
        let height = this.$el.parentElement.clientHeight
        let url = utils.prefixWithBase("/frontend/" + this.screenId + "/fields/" + this.field.id + "/contents.json?width=" + width + '&height=' + height, this.baseUrl);
        return axios.get(url)
          .then((response) => {
            let data = response.data
            let key = response.headers['x-concerto-frontend-setup-key']

            // only process the contents if the frontend key is the same otherwise the screen is going to reload the page anyway so dont bother
            if (this.isSameFrontendKey(key)) {
              // since there really is no data for the Time field, mock up an entry
              if (this.field.name === "Time") {
                this.status = this.timezone || 'No timezone specified'
                this.status += ', ' + (this.locale || 'No locale specified')
                data = [{
                  'duration': 15,
                  'id': Date.now(), // must be differing so each item is treated as new content
                  'name': 'System Time',
                  'type': 'ClientTime',
                  'render_details': {'timezone': this.timezone, 'locale': this.locale}
                }]
              }

              if (data === null || data.length === 0) {
                this.status = 'no content returned, trying again in 10 seconds'
                data = [ this.emptyContent ];
              }
            }

            // console.debug(this.field.id, this.field.name, 'data', data)
            // add it to the queue
            Array.prototype.push.apply(this.contentQueue, data);
            // dont wait to show it if we are currently not showing anything
            if ((!this.currentContent || this.currentContent.type == 'Empty') && this.contentQueue.length >= 1) {
              this.scheduleNextContent(1);
            }

            return data
          })
          .catch((error) => {
            this.status = "An error has occurred " + error.message
            let data = [{
              'duration': 10,
              'id': Date.now(), // must be differing so each item is treated as new content
              'name': 'Error',
              'type': 'HtmlText',
              'render_details': { data: 'An error has occurred - ' + error.message }
            }]
            // an error ocurred, so tell the screen to reload -- it has a nicer error msg
            this.$emit('frontend-key-changed')
            return data
          })
      },


      /**
       * Schedule an attempt to load the next piece of content for this field.
       *
       * @function scheduleNextContent
       * @param {Number} msToWait Number of milliseconds to wait.
       */
      scheduleNextContent(msToWait) {
        if (this.debouncedScheduleNextContent) {
          console.debug(this.field.id, this.field.name, 'ignoring schedule next content request since already pending')
          return
        }
        // keep track of our debounced function so we can flush it later if needed, but if we've been called already
        // then clear our track so we dont try and flush it later.
        this.debouncedScheduleNextContent = utils.debounce(() => {
          this.debouncedScheduleNextContent = null
          this.loadNextContent()
        }, msToWait)
        this.debouncedScheduleNextContent()
      },


      /**
       * Load a piece of content based on the content data.
       *
       * @function loadContent
       * @param {Object} contentData
       * @returns {Boolean} Return true if the content started loading OK.
       */
      loadContent (contentData) {
        if (!contentData) {
          this.status = 'Missing contentData'
          console.error(this.field.id, this.field.name, 'invalid contentData')
          return false;
        }

        let simpleContentData = {
          title: contentData.name,
          contentId: contentData.id,
          duration: contentData.duration,
          config: this.field.config,
          baseUrl: this.baseUrl,
          type: contentData.type,
          fieldHeight: this.$el.offsetHeight,
          fieldWidth: this.$el.offsetWidth
        };

        // Flatten render_details
        Object.keys(contentData.render_details).forEach(function(key) {
          simpleContentData[key] = contentData.render_details[key];
        });

        this.contentType = 'Concerto' + contentData.type;
        this.currentContent = [simpleContentData];

        // console.debug('scheduling next content load for ', simpleContentData.duration * 1000)
        this.scheduleNextContent(simpleContentData.duration * 1000)
        return true;
      },


      loadNextContent () {
        let newContent = this.contentQueue.shift();

        // If we got nothing from the queue or it is empty then fetch more, but continue on (since we might
        // have grabbed the last item from the queue and still need to show it).
        if (!newContent || this.contentQueue.length < 1) {
          // console.debug(this.field.id, this.field.name, 'queue is empty now so fetching more')
          this.fetchContent();
        }

        if (!newContent) {
          // This happens when we empty the queue and the fetchContent routine hasn't completed yet.
          // There was no content in the queue, try again in a few seconds.
          this.scheduleNextContent(10 * 1000);
          return false
        } 

        // If we have a current item and the new item is the same, then if we are supposed to suppress it, skip the new item.
        // This does not apply to RemoteVideo content since that should restart the video.
        if (this.currentContent && this.currentContent.length > 0 && this.currentContent[0].contentId === newContent.id && this.suppressRepeatingContent && newContent['type'] !== 'RemoteVideo') {
          this.status = 'skipping same piece of content: ' + newContent.id + ' - ' + newContent.name
          // console.debug(Date(), this.field.id, this.field.name, this.status, this.contentQueue.length)
          // if there is more stuff in the queue, then go right to the next item, otherwise, we dont want to thrash if we only have one item on the feed,
          // peek in the queue and see if it is filled with the same
          let delay = 1
          if (this.contentQueue.length == 0 || (this.contentQueue.length == 1 && this.contentQueue[0].id === newContent.id)) {
            // console.debug('showing repeat content anyway since it appears to be the only item')
            this.currentContent[0].duration = newContent.duration
            delay = newContent.duration * 1000
          }
          this.scheduleNextContent(delay);
          return true;
        }

        // If we have a current item, but the new item is empty AND the field is supposed to leave the last item shown, then skip the new item
        // and check for a new item in 10 seconds-- not the items duration again since we are already beyond that.
        if (this.currentContent && this.currentContent.length > 0 && newContent.type === 'Empty' && !this.clearContentWhenEmpty) {
          this.status = 'leaving last piece of content, trying again in 10 seconds'
          console.debug(this.field.id, this.field.name, this.status)
          this.scheduleNextContent(10 * 1000);
          return true;
        }

        if (!this.loadContent(newContent)) {
          // The content failed to load.
          console.log(this.field.id, this.field.name, 'Unable to load ' + newContent.type + ' content')
          this.contentErrorCount++;
          // Allow the field to retry 5 times quickly.
          if (this.contentErrorCount <= 5) {
            // Move on to the next content -- instead of calling recursively, use the scheduler
            // this.loadNextContent();
            if (this.debouncedScheduleNextContent !== null) {
              // if there is a pending call then do it now
              this.debouncedScheduleNextContent.flush()
            } else {
              this.scheduleNextContent(10 * 1000);
              this.status = 'Retrying ' + this.contentErrorCount + ' in 10 seconds.'
              console.debug(this.field.id, this.field.name, this.status);
            }
          } else {
            // try again in half minute increments up to ten minutes since we are having problems fetching data
            let retryDuration = Math.min((this.contentErrorCount - 1) * 30, 1200);
            this.status = 'Retrying ' + this.contentErrorCount + ' in ' + retryDuration + ' seconds.'
            console.debug(this.field.id, this.field.name, this.status);
            this.scheduleNextContent(retryDuration * 1000);
          }
          return false
        } else {
          // The content loaded sucessfully.
          this.contentErrorCount = 0
          this.lastUpdated = Date.now()
          this.status = 'Content ' + this.currentContent[0].contentId + ' - ' + this.currentContent[0].title
          return true
        }
        
      },
    }
  }
</script>

<style>
  .concerto-field {
    display: block;
    width: 100%;
    height: 100%
  }
</style>