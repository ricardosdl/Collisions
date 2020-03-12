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
Global CenterRect.TRect, MouseRect.TRect, CenterLine.TLine, ClosestPoint.TPoint, MouseLine.TLine
Global CollisionPoint.TPoint, DrawCollisionPoint.a = #False

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

Procedure.a CollisionLinePoint(*Line.TLine, *Point.TPoint)
  Dist1.f = Distance(*Point\x, *Point\y, *Line\x1, *Line\y1)
  Dist2.f = Distance(*Point\x, *Point\y, *Line\x2, *Line\y2)
  LineLength.f = Distance(*Line\x1, *Line\y1, *Line\x2, *Line\y2)
  Buffer.f = 0.1
  ProcedureReturn Bool(Dist1 + Dist2 >= LineLength - Buffer And Dist1 + Dist2 <= LineLength + Buffer)
EndProcedure

Procedure.a CollisionLineCircle(*Line.TLine, *Circle.TCircle, *ClosestPoint.TPoint = #Null)
  LinePoint1.TPoint\x = *Line\x1 : LinePoint1\y = *Line\y1
  LinePoint2.TPoint\x = *Line\x2 : LinePoint2\y = *Line\y2
  Inside.a = Bool(CollisionPointCircle(LinePoint1, *Circle) Or CollisionPointCircle(LinePoint2, *Circle))
  If Inside : ProcedureReturn #True : EndIf
  LineLength.f = Distance(*Line\x1, *Line\y1, *Line\x2, *Line\y2)
  Dot.f = ((*Circle\x - *Line\x1) * (*Line\x2 - *Line\x1) + (*Circle\y - *Line\y1) * (*Line\y2 - *Line\y1)) / Pow(LineLength, 2)
  ClosestPointOnLine.TPoint\x = *Line\x1 + (Dot * (*Line\x2 - *Line\x1))
  ClosestPointOnLine\y = *Line\y1 + (Dot * (*Line\y2 - *Line\y1))
  If *ClosestPoint <> #Null : CopyStructure(@ClosestPointOnLine, *ClosestPoint, TPoint) : EndIf
  OnLineSegment.a = CollisionLinePoint(*Line, ClosestPointOnLine)
  If Not OnLineSegment : ProcedureReturn #False : EndIf
  DistancePointCircle.f = Distance(ClosestPointOnLine\x, ClosestPointOnLine\y, *Circle\x, *Circle\y)
  ProcedureReturn Bool(DistancePointCircle <= *Circle\Radius)
EndProcedure

Procedure.a CollisionLineLine(*Line1.TLine, *Line2.TLine, *CollisionPoint.TPoint = #Null)
  X1.f = *Line1\x1 : Y1.f = *Line1\y1 : X2.f = *Line1\x2 : Y2.f = *Line1\y2
  X3.f = *Line2\x1 : Y3.f = *Line2\y1 : X4.f = *Line2\x2 : Y4.f = *Line2\y2
  Ua.f = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1))
  Ub.f = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1))
  Collided.a = Bool(uA >= 0 And uA <= 1 And uB >= 0 And uB <= 1)
  If *CollisionPoint <> #Null And Collided
    *CollisionPoint\x = x1 + (uA * (x2-x1)) : *CollisionPoint\y = y1 + (uA * (y2-y1))
  EndIf
  ProcedureReturn Collided
EndProcedure




Procedure Setup()
  MouseLine\x1 = 0 : MouseLine\y1 = 0 : MouseLine\x2 = 10 : MouseLine\y2 = 10
  CenterLine\x1 = 100 : CenterLine\y1 = 300 : CenterLine\x2 = 500 : CenterLine\y2 = 100
EndProcedure

Procedure Update(Elapsed.f)
  MouseLine\x1 = MouseX() : MouseLine\y1 = MouseY()
  
  If CollisionLineLine(@MouseLine, @CenterLine, @CollisionPoint)
    CollisionColor = RGB(255, 150, 0) : DrawCollisionPoint = #True
  Else
    CollisionColor = RGB(0, 150, 255) : DrawCollisionPoint = #False
  EndIf
EndProcedure

Procedure Draw()
  StartDrawing(ScreenOutput())
  LineXY(CenterLine\x1, CenterLine\y1, CenterLine\x2, CenterLine\y2, CollisionColor)
  LineXY(MouseLine\x1, MouseLine\y1, MouseLine\x2, MouseLine\y2, CollisionColor)
  If DrawCollisionPoint
    Circle(CollisionPoint\x, CollisionPoint\y, 5, RGB(255, 0, 0))
  EndIf
  
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