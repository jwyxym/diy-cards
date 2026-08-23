--老牧师手法
local s,id,o=GetID()
function s.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.eftg)
	e1:SetOperation(s.efop)
	c:RegisterEffect(e1)
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
end    
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>0 then return end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    local c=e:GetHandler()    
	--骰子    
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TOSS_DICE_NEGATE)
	e1:SetOperation(s.dcop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--硬币    
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TOSS_COIN_NEGATE)
	e2:SetOperation(s.coop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)    
end
function s.dcop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_CARD,0,id)
		local dc={Duel.GetDiceResult()}
		local ac=1
		local ct=(ev&0xff)+(ev>>16&0xff)
        for i=1,ct do
        	if i>1 then 
            	if not Duel.SelectYesNo(tp,aux.Stringid(id,5)) then break
				else Duel.BreakEffect() end
			end
			if ct>1 then			
				Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
				local val,idx=Duel.AnnounceNumber(tp,table.unpack(aux.idx_table,1,ct))
				ac=idx+1
			end
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))
			local newval=Duel.AnnounceNumber(tp,1,2,3,4,5,6)
			dc[ac]=newval
			Duel.SetDiceResult(table.unpack(dc))
       	end     
	end
end
function s.coop(e,tp,eg,ep,ev,re,r,rp)	
	if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_CARD,0,id)
		local co={Duel.GetCoinResult()}
		local ac=1
    	local ct=(ev&0xff)+(ev>>16&0xff)
		for i=1,ct do
    		if i>1 then 
            	if not Duel.SelectYesNo(tp,aux.Stringid(id,6)) then break
				else Duel.BreakEffect() end
			end
        	if ct>1 then			
				Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
				local val,idx=Duel.AnnounceNumber(tp,table.unpack(aux.idx_table,1,ct))
				ac=idx+1
			end
        	local newval=aux.SelectFromOptions(tp,{true,60,1},{true,61,0})
			co[ac]=newval
			Duel.SetCoinResult(table.unpack(co))
 		end           
	end            
end