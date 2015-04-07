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

function TweenAction(tween) {
    this.tween = tween;
}

TweenAction.prototype = {
    start: function() {
	this.tween.onComplete.add(this.onComplete, this);
	this.tween.start();
    }
}
