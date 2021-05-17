import $ from "jquery";

let Taut = {
	update_ats: function() {
		$("span[data-at]").each(function(at) {
          		var ts = new Date($(this).attr("data-at"));
          		var formatter = new Intl.DateTimeFormat("default", {
						month: "numeric", day: "numeric", year: "2-digit",
						weekday: "short", hour: "numeric", minute: "2-digit"
          		});
          		$(this).html(formatter.format(ts));
		});
	},

	autogrow: function(el) {
		el.style.height = (el.scrollHeight)+"px";
    },

	TautHooks: {
		TautMessageHooks: {
				mounted() {
                		this.el.scrollTop = this.el.scrollHeight;
						Taut.update_ats();
        		},
        		updated() {
                		this.el.scrollTop = this.el.scrollHeight;
						Taut.update_ats();
        		}
		}
	}
};

$("body").on("keypress", "div.taut_input textarea", function(e) {
		if ((e.which === 13) && !e.shiftKey) {
				e.preventDefault();
				$("div.taut_input form")[0].dispatchEvent(new Event("submit", {bubbles: true}));
		}
});

export { Taut };



