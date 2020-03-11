Structure TPoint
  x.f : y.f
EndStructure
Structure TCircle
  x.f : y.f : Radius.f
EndStructure
Global ElapsedTimneInS.f, LastTimeInMs.q, ExitGame.a = #False
Global MousePoint.TPoint, CenterPoint.TPoint, Circle.TCircle, MouseCircle.TCircle, CircleColor.i = RGB(0, 150, 255)

Procedure.a CollisionPointPoint(x1.f, y1.f, x2.f, y2.f)
  ProcedureReturn Bool(x1 = x2 And y1 = y2)
EndProcedure

Procedure.a CollisionPointCircle(*Point.TPoint, *Circle.TCircle)
  DistX.f = *Point\x - *Circle\x : DistY.f = *Point\y - *Circle\y
  Distance.f = Sqr((DistX * DistX) + (DistY * DistY))
  ProcedureReturn Bool(Distance <= *Circle\Radius)
EndProcedure

Procedure.a CollisionCircleCircle(*Circle1.TCircle, *Circle2.TCircle)
  DistX.f = *Circle1\x - *Circle2\x : DistY.f = *Circle1\y - *Circle2\y
  ProcedureReturn Bool(Abs((DistX * DistX) + (DistY * DistY)) <= Pow(*Circle1\Radius + *Circle2\Radius, 2))
EndProcedure

Procedure Setup()
  Circle\x = 400 : Circle\y = 300 : Circle\Radius = 100
  MouseCircle\x = 0 : MouseCircle\y = 0 : MouseCircle\Radius = 30
EndProcedure

Procedure Update(Elapsed.f)
  MousePoint\x = MouseX() : MousePoint\y = MouseY()
  
  MouseCircle\x = MouseX() : MouseCircle\y = MouseY()
  
  If CollisionCircleCircle(@MouseCircle, @Circle)
    CircleColor = RGB(255, 150, 0)
    DistX.f = MouseCircle\x - Circle\x : DistY.f = MouseCircle\y - Circle\y
    Distance = Sqr((DistX * DistX) + (DistY * DistY))
    MidPointX.f = (MouseCircle\x + Circle\x) / 2
    MidPointY.f = (MouseCircle\y + Circle\y) / 2
    MinDistance.f = MouseCircle\Radius + Circle\Radius + 1.0
    ;MouseCircle\x = MidPointX + MouseCircle\Radius * (MouseCircle\x - Circle\x) / Distance
    ;MouseCircle\y = MidPointY + MouseCircle\Radius * (MouseCircle\y - Circle\y) / Distance
    Circle\x = MidPointX + Circle\Radius * (Circle\x  - MouseCircle\x) / Distance
    Circle\y = MidPointY + Circle\Radius * (Circle\y  - MouseCircle\y) / Distance
  Else
    CircleColor = RGB(0, 150, 255)
  EndIf
  
  
  
EndProcedure

Procedure Draw()
  StartDrawing(ScreenOutput())
  ;Plot(CenterPoint\x, CenterPoint\y, RGB($FF, $AA, $10))
  Circle(Circle\x, Circle\y, Circle\Radius, CircleColor)
  
  ;Plot(MousePoint\x, MousePoint\y, RGB(0, $F5, $10))
  Circle(MouseCircle\x, MouseCircle\y, MouseCircle\Radius, RGB(0, $F5, $10))
  StopDrawing()
EndProcedure


Procedure RenderFrame()
  ElapsedTimneInS = (ElapsedMilliseconds() - LastTimeInMs) / 1000.0
  If ElapsedTimneInS >= 0.05 : ElapsedTimneInS = 0.05 : EndIf
  CompilerIf #PB_Compiler_Processor <> #PB_Processor_JavaScript
    Repeat; Always process all the events to flush the queue at every frame
      Event = WindowEvent()
      Select Event
        Case #PB_Event_CloseWindow
          ExitGame = #True
      EndSelect
    Until Event = 0 ; Quit the event loop only when no more events are available
  CompilerEndIf
  ExamineKeyboard() : ExamineMouse()
  Update(ElapsedTimneInS)
  ClearScreen(RGB(0, 0, 0))
  Draw()
  LastTimeInMs = ElapsedMilliseconds()
  FlipBuffers()
EndProcedure
If InitSprite() = 0 Or InitKeyboard() = 0
  MessageRequester("Error", "Sprite system or keyboard system can't be initialized", 0)
EndIf
InitMouse()
If OpenWindow(0, 0, 0, 800, 600, "Collisions", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  If OpenWindowedScreen(WindowID(0), 0, 0, 800, 600, 0, 0, 0)
    Setup()
    LastTimeInMs = ElapsedMilliseconds()
    Repeat
      RenderFrame()
    Until ExitGame
  EndIf
EndIf