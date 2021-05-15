let TautHooks = {};
TautHooks.Taut = {
		mounted() {
                this.el.scrollTop = this.el.scrollHeight;
        },
        updated() {
                this.el.scrollTop = this.el.scrollHeight;
        }
};

export { TautHooks };

