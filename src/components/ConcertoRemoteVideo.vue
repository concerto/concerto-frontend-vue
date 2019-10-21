<template>
  <div class="concerto-video-container"> 
    <iframe v-if="!useVideo" class="concerto-remote-video" :src="content.path" frameBorder="0" scrolling="no" allow="autoplay; fullscreen" :style="content.style"></iframe>
    <video v-if="useVideo" class="concerto-remote-video" :src="content.path" autoplay="true" :style="content.style"></video>
  </div>
</template>

<script>
  export default {
    name: 'ConcertoIframe',
    props: {
      content: Object
    },
    computed: {
      useVideo: function() {
        return this.content.path.includes('http_video=true')
      }
    }
  }
</script>

<style>
  .concerto-video-container, .concerto-remote-video {
    position: absolute;
    display: block;
    width: 100%;
    height: 100%;
  }
</style>
