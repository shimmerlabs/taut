import $ from "jquery";

function update_ats() {
		$("span[data-at]").each(function(at) {
          		var ts = new Date($(this).attr("data-at"));
          		var formatter = new Intl.DateTimeFormat("default", {
						month: "numeric", day: "numeric", year: "2-digit",
						weekday: "short", hour: "numeric", minute: "2-digit"
          		});
          		$(this).html(formatter.format(ts));
		});
}

let TautHooks = {};
TautHooks.Taut = {
		mounted() {
                this.el.scrollTop = this.el.scrollHeight;
				update_ats();
        },
        updated() {
                this.el.scrollTop = this.el.scrollHeight;
				update_ats();
        }
};

export { TautHooks };



