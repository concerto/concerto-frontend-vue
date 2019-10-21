<template>
  <iframe class="concerto-iframe" :src="content.path" frameBorder="0" scrolling="no" :style="content.style" ></iframe>
</template>

<script>
  export default {
    name: 'ConcertoIframe',
    props: {
      content: Object
    },
  }
</script>

<style>
  .concerto-iframe {
    display: block;
    position: absolute;
    width: 100%;
    height: 100%;
  }
</style>

