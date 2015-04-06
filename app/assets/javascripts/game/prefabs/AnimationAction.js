function AnimationAction(sprite, anim) {
    this.sprite = sprite;
    this.anim = anim;
}

AnimationAction.prototype = {
    start: function() {
	this.sprite.events.onAnimationComplete.addOnce(this.onComplete, this);
	this.sprite.animations.play(this.anim, 2, false);
    }
}
