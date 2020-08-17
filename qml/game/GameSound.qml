import Felgo 3.0
import QtQuick 2.0
//import QtMultimedia 5.0


Item {
  id: gameSound

  // game sound effects
  SoundEffect {
    id: moveBlock
    source: "../../assets/snd/NFF-switchy.wav"
  }

  SoundEffect {
    id: moveBlockBack
    source: "../../assets/snd/NFF-switchy-02.wav"
  }

  SoundEffect {
    id: fruitClear
    source: "../../assets/snd/NFF-fruit-collected.wav"
  }

  SoundEffect {
    id: overloadClear
    source: "../../assets/snd/NFF-fruit-appearance.wav"
  }

  SoundEffect {
    id: upgrade
    source: "../../assets/snd/NFF-upgrade.wav"
  }

  // text (overlay) SoundEffects
  SoundEffect {
    id: overloadSound
    autoPlay: false
    source: "../../assets/snd/texts/JuicyOverload.wav"
  }

  SoundEffect {
    id: fruitySound
    autoPlay: false
    source: "../../assets/snd/texts/Fruity.wav"
  }

  SoundEffect {
    id: sweetSound
    autoPlay: false
    source: "../../assets/snd/texts/Sweet.wav"
  }

  SoundEffect {
    id: refreshingSound
    autoPlay: false
    source: "../../assets/snd/texts/Refreshing.wav"
  }

  SoundEffect {
    id: yummySound
    autoPlay: false
    source: "../../assets/snd/texts/Yummy.wav"
  }

  SoundEffect {
    id: deliciousSound
    autoPlay: false
    source: "../../assets/snd/texts/Delicious.wav"
  }

  SoundEffect {
    id: smoothSound
    autoPlay: false
    source: "../../assets/snd/texts/Smooth.wav"
  }

  // functions to play sounds
  function playMoveBlock() { moveBlock.stop(); moveBlock.play() }
  function playMoveBlockBack() { moveBlock.stop(); moveBlockBack.play() }
  function playFruitClear() { fruitClear.stop(); fruitClear.play() }
  function playOverloadClear() {  overloadClear.stop(); overloadClear.play() }
  function playUpgrade() { upgrade.stop(); upgrade.play() }

  function playFruitySound() {  fruitySound.stop(); fruitySound.play() }
  function playSweetSound() {  sweetSound.stop(); sweetSound.play() }
  function playRefreshingSound() {  refreshingSound.stop(); refreshingSound.play() }
  function playOverloadSound() {  overloadSound.stop(); overloadSound.play() }
  function playYummySound() {  yummySound.stop(); yummySound.play() }
  function playDeliciousSound() {  deliciousSound.stop(); deliciousSound.play() }
  function playSmoothSound() {  smoothSound.stop(); smoothSound.play() }
}
