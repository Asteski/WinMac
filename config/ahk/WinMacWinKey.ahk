ih := InputHook('L1')

LWin Up::ih.Stop
LWin:: {
 ih.Start(), ih.Wait()
 Send '#' (ih.Input = '' ? 'x' : ih.Input)
}