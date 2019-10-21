<template>
  <div class="concerto-empty"><span/></div>
</template>

<script>
  export default {
    name: 'ConcertoEmpty',
    props: {
      content: Object // not used
    }
  }
</script>

<style>
  .concerto-empty {
    opacity: 0.2;
    background-color: transparent;
    display: flex;
    align-items: center;
    justify-content: center;
    height: 100%;
  }
    .concerto-empty span:before {
      content: '...'
    }
</style>
