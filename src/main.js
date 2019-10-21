import Vue from 'vue'
import App from './App.vue'

// these animations are used in ConcertoField
import Animate from './assets/animate.css'

Vue.config.productionTip = false

// Use properties of root element - see https://forum.vuejs.org/t/passing-props-to-root-instances-in-2-0/244/15

const rootEl = document.getElementById('app')
const AppRoot = Vue.extend(App)

new AppRoot({
  el: rootEl,
  propsData: {
    screenId: rootEl.getAttribute('screen-id'),
    preview: rootEl.getAttribute('preview') === 'true',
    debug: rootEl.getAttribute('debug') === 'true',
    baseUrl: rootEl.getAttribute('base-url'),
  }
})

