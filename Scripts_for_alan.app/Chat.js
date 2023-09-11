intent(
    'What is your name',
    'Wow are you',p => {
        p.play('I am Charles!');
    }
)

intent(
    'Navigate (to| me to) Yolo page',
    p => {
        p.play({"command":"Tiny YOLOv2"});
        p.play("Navigating to Yolo page");
    }
)

intent(
    'Navigate (to| me to) SSD page',
    p => {
        p.play({"command":"SSD"});
        p.play("Navigating to SSD Page");
    }
)

intent(
    'Navigate (to| me to) MobileNet page',
    p => {
        p.play({"command":"MobileNet"});
        p.play("Navigating to MobileNet Page");
    }
)

intent(
    'Navigate (to| me to) PoseNet page',
    p => {
        p.play({"command":"PoseNet"});
        p.play("Navigating to PoseNet Page");
    }
)