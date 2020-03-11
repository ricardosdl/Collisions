Structure TPoint
  x.f : y.f
EndStructure
Structure TCircle
  x.f : y.f : Radius.f
EndStructure
Structure TRect
  x.f : y.f : Width.f : Height.f
EndStructure
Structure TLine
  x1.f : y1.f : x2.f : y2.f
EndStructure

Global ElapsedTimneInS.f, LastTimeInMs.q, ExitGame.a = #False
Global MousePoint.TPoint, CenterPoint.TPoint, Circle.TCircle, MouseCircle.TCircle, CollisionColor.i = RGB(0, 150, 255)
Global CenterRect.TRect, MouseRect.TRect, CenterLine.TLine

Procedure.f Distance(x1.f, y1.f, x2.f, y2.f)
  DistX.f = x1 - x2 : DistY.f = y1 - y2
  ProcedureReturn Sqr(Pow(DistX, 2) + Pow(DistY, 2))
EndProcedure

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

Procedure.a CollisionPointRect(*Point.TPoint, *Rect.TRect)
  RightAndLeft.a = Bool(*Point\x >= *Rect\x And *Point\x <= *Rect\x + *Rect\Width)
  BelowAndAbove.a = Bool(*Point\y >= *Rect\y And *Point\y <= *Rect\y + *Rect\Height)
  ProcedureReturn Bool(RightAndLeft And BelowAndAbove)
EndProcedure

Procedure.a CollisionRectRect(*Rect1.TRect, *Rect2.TRect)
  RightAndLeft.a = Bool(*Rect1\x + *Rect1\Width >= *Rect2\x And *Rect1\x <= *Rect2\x + *Rect2\Width)
  TopAndBottom.a = Bool(*Rect1\y + *Rect1\Height >= *Rect2\y And *Rect1\y <= *Rect2\y + *Rect2\Height)
  ProcedureReturn Bool(RightAndLeft And TopAndBottom)
EndProcedure

Procedure.a CollisionLinePoint(*Line.TLine, *Point.TPoint)
  Dist1 = Distance(*Point\x, *Point\y, *Line\x1, *Line\y1)
  Dist2 = Distance(*Point\x, *Point\y, *Line\x2, *Line\y2)
  LineLength.f = Distance(*Line\x1, *Line\y1, *Line\x2, *Line\y2)
  Buffer.f = 0.1
  ProcedureReturn Bool(Dist1 + Dist2 >= LineLength - Buffer And Dist1 + Dist2 <= LineLength + Buffer)
EndProcedure

Procedure.a CollisionCircleRect(*Circle.TCircle, *Rect.TRect)
  TestX.f = *Circle\x : TestY.f = *Circle\y
  If *Circle\x < *Rect\x
    TestX = *Rect\x
  ElseIf *Circle\x > *Rect\x + *Rect\Width
    TestX = *Rect\x + *Rect\Width
  EndIf
  If *Circle\y < *Rect\y
    TestY = *Rect\y
  ElseIf *Circle\y > *Rect\y + *Rect\Height
    TestY = *Rect\y + *Rect\Height
  EndIf
  DistX.f = *Circle\x - TestX : DistY.f = *Circle\y - TestY
  ProcedureReturn Bool((DistX * DistX + DistY * DistY) <= Pow(*Circle\Radius, 2))
EndProcedure



Procedure Setup()
  MousePoint\x = 0 : MousePoint\y = 0
  CenterLine\x1 = 100 : CenterLine\y1 = 300 : CenterLine\x2 = 500 : CenterLine\y2 = 100
EndProcedure

Procedure Update(Elapsed.f)
  MousePoint\x = MouseX() : MousePoint\y = MouseY()
  
  If CollisionLinePoint(@CenterLine, @MousePoint)
    CollisionColor = RGB(255, 150, 0)
  Else
    CollisionColor = RGB(0, 150, 255)
  EndIf
EndProcedure

Procedure Draw()
  StartDrawing(ScreenOutput())
  LineXY(CenterLine\x1, CenterLine\y1, CenterLine\x2, CenterLine\y2, CollisionColor)
  ;Box(CenterPoint\x, CenterPoint\y, 5, CenterRect\Height, CollisionColor)
  Circle(MousePoint\x, MousePoint\y, 5, RGB(0, $F5, $10))
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