<template>
  <div id="app">
    <ConcertoScreen :screen="screen" :debug="isDebug"/>
  </div>
</template>

<script>
  import ConcertoScreen from './components/ConcertoScreen.vue'

  export default {
    name: 'App',
    components: {
      ConcertoScreen
    },
    props: {
      debug: Boolean,
      screenId: String,
      preview: Boolean,
      baseUrl: String
    },
    data: function() {
      return {
        isDebug: this.debug,
        screen: {
          id: this.screenId,
          isPreview: this.preview,
          baseUrl: this.baseUrl
        }
      }
    }
  }
</script>

<style>
  #app {
    display: block;
    width: 100%;
    height: 100%;
  }

  html, body {
    width: 100%;
    height: 100%;
    margin: 0;
    padding: 0;
  }
</style>