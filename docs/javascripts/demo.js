/* Mounts the playable demo iframes on the mi_minigame and mi_coopminigames pages.
 *
 * The iframe is created on click instead of sitting in the markup, for two reasons:
 *
 *  - Keyboard. An iframe the visitor has not clicked does not hold focus, so SPACE and the arrows
 *    (which is how most of these games commit) scroll the docs page instead of reaching the game.
 *    A click is exactly the gesture that hands focus over, so the cover doubles as the fix.
 *  - Weight. Each build is around 250 KB of JS. Most people opening this page came to read the
 *    export signature, and they should not pay for a bundle they never play.
 *
 * `document$` is Material's per-page observable. Plain DOMContentLoaded would fire once and then
 * never again, because navigation.instant swaps page content without a reload.
 */
document$.subscribe(function () {
  document.querySelectorAll('.mi-demo').forEach(function (box) {
    if (box.dataset.wired) return;
    box.dataset.wired = '1';

    var cover = box.querySelector('.mi-demo-cover');
    if (!cover || !box.dataset.src) return;

    cover.addEventListener('click', function (event) {
      // The "open in a new tab" link lives inside the cover; let it through.
      if (event.target.closest('a')) return;

      var frame = document.createElement('iframe');
      frame.src = box.dataset.src;
      frame.title = box.dataset.title || 'Playable demo';
      frame.setAttribute('allow', 'autoplay');
      frame.addEventListener('load', function () {
        try {
          frame.contentWindow.focus();
        } catch (e) {
          /* same-origin here, but never let a focus failure break the page */
        }
      });

      box.appendChild(frame);
      box.classList.add('playing');
    });
  });
});
