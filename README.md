
# Software for the Padauk PMS150C to control a toy train locomotive (the original mcu was fried)

<img src="img/pcb.jpg" width="512">


```
                                   _____________
                                  / _           \
                             3V -| (_)           |- GND
                                 |               |
   backward button (active low) -|   PMS150C     |- backward ctl
                                 |               |
    forward button (active low) -|   SOIC-8      |- forward ctl
                                 |               |
       stop button (active low) -|               |- not connected
                                  \_____________/

```

|              | backward ctl | forward ctl |
| ------------ | ------------ | ----------- |
|   off        | low          | low         |
| forward      | low          | high        |
| backward     | high         | low         |
| bad times(?) | high         | high        |

<img src="img/open.jpg" width="512">
<img src="img/closed.jpg" width="512">

