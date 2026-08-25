/**
 * Blog index tag filter. Default is chronological.
 * Clicking #tags in the picker (or a post) filters the list (OR, toggle).
 * Hash: #tag-slug or #tag-a+b
 */
(() => {
	function init() {
		const picker = document.querySelector(".blog-tag-picker");
		if (!picker) return;

		const chips = [...document.querySelectorAll(".blog-tag-filter")];
		const showAll = picker.querySelector(".blog-show-all");
		const years = [...document.querySelectorAll(".blog-year")];
		const entries = [...document.querySelectorAll(".blog-entry")];

		function parseHash() {
			const raw = (location.hash || "").replace(/^#/, "");
			if (raw.startsWith("tag-")) {
				const body = raw.slice(4);
				return body ? body.split("+").filter(Boolean) : [];
			}
			return [];
		}

		function writeHash(slugs) {
			const hash = slugs.length ? "#tag-" + slugs.join("+") : "";
			if ((location.hash || "") !== hash) {
				history.replaceState(null, "", hash ? hash : location.pathname + location.search);
			}
		}

		function apply(slugs) {
			picker.classList.toggle("is-filtered", slugs.length > 0);
			picker.querySelectorAll(".blog-tag-filter").forEach((chip) => {
				chip.classList.toggle("is-active", slugs.includes(chip.dataset.tag));
			});
			years.forEach((el) => {
				el.hidden = slugs.length > 0;
			});
			entries.forEach((entry) => {
				if (slugs.length === 0) {
					entry.hidden = false;
					entry.classList.remove("is-selected");
					entry.querySelectorAll(".blog-tag-filter").forEach((tag) => {
						tag.classList.remove("is-active");
					});
					return;
				}
				const tags = (entry.dataset.tags || "").split(/\s+/).filter(Boolean);
				const match = slugs.some((slug) => tags.includes(slug));
				entry.hidden = !match;
				entry.classList.toggle("is-selected", match);
				entry.querySelectorAll(".blog-tag-filter").forEach((tag) => {
					tag.classList.toggle("is-active", slugs.includes(tag.dataset.tag));
				});
			});
			writeHash(slugs);
		}

		chips.forEach((chip) => {
			chip.addEventListener("click", (event) => {
				event.preventDefault();
				const slug = chip.dataset.tag;
				let slugs = parseHash();
				if (slugs.includes(slug)) {
					slugs = slugs.filter((s) => s !== slug);
				} else {
					slugs = [...slugs, slug];
				}
				apply(slugs);
			});
		});

		if (showAll) {
			showAll.addEventListener("click", (event) => {
				event.preventDefault();
				apply([]);
			});
		}

		window.addEventListener("hashchange", () => apply(parseHash()));
		apply(parseHash());
	}

	if (document.readyState === "loading") {
		document.addEventListener("DOMContentLoaded", init);
	} else {
		init();
	}
})();
