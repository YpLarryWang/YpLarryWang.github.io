/**
 * Shows one randomly chosen image out of each `.random-image` group.
 *
 * All candidates are present in the HTML, so with JavaScript disabled the
 * first one simply stays visible (see the CSS rule in tufted.css).
 */
(() => {
	function pickOne(group) {
		// Each candidate is a `.random-item` wrapping an image and its caption,
		// so the two always travel together. Older markup with bare images is
		// still handled.
		let candidates = Array.from(group.querySelectorAll(":scope > .random-item"));
		if (candidates.length === 0) {
			candidates = Array.from(group.querySelectorAll("img"));
		}
		if (candidates.length < 2) {
			return;
		}

		const chosen = candidates[Math.floor(Math.random() * candidates.length)];
		candidates.forEach((el) => {
			el.classList.toggle("is-shown", el === chosen);
		});
	}

	function init() {
		document.querySelectorAll(".random-image").forEach(pickOne);
	}

	if (document.readyState === "loading") {
		document.addEventListener("DOMContentLoaded", init);
	} else {
		init();
	}
})();
