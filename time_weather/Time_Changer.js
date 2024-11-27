/// <reference path=".config/sa.d.ts" />

var pause = false;
var pause_start_time = 0;

var hours = Clock.GetTimeOfDay().hours || 0;

while (true) {
    wait(0);

    Clock.SetTimeOfDay(hours, 0); 

    if (!pause) {
        if (Pad.IsKeyPressed(18) && Pad.IsKeyPressed(187)) {
            if (hours == 23) {
                hours = 0;
            } else {
                hours++;
            }
            pause = true;
            pause_start_time = Date.now();
        } else if (Pad.IsKeyPressed(18) && Pad.IsKeyPressed(189)) {
            if (hours == 0) {
                hours = 23;
            } else {
                hours--;
            }
            pause = true;
            pause_start_time = Date.now();
        }
    }

    if (pause) {
        if (Date.now() - pause_start_time > 1000) {
            pause = false;
        }
    }
}
