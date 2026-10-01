--神醒的神灾
local s,id,o=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c,false)
	--超量召唤    
    aux.AddXyzProcedure(c,s.matfilter,6,2,s.ovfilter,aux.Stringid(id,6),99,s.xyzop)
    c:EnableReviveLimit()
	--加入额外
	local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetRange(LOCATION_PZONE)
	e0:SetCondition(s.txcon)
	e0:SetTarget(s.txtg)
	e0:SetOperation(s.txop)
	c:RegisterEffect(e0)
	--抽卡
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_RELEASE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.drcon)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	--解放
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCost(s.rlcost)
	e2:SetTarget(s.rltg)
	e2:SetOperation(s.rlop)
	c:RegisterEffect(e2)        
	--放置    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_RELEASE)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.pencon)
	e3:SetTarget(s.pentg)
	e3:SetOperation(s.penop)
	c:RegisterEffect(e3)
	--加入额外    
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(s.SpiritReturnReg)
	c:RegisterEffect(e4)            
    if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.matfilter(c)
	return c:IsXyzType(TYPE_RITUAL) and c:IsXyzType(TYPE_PENDULUM) and c:IsXyzType(TYPE_SPIRIT)
end
function s.ovfilter(c)
	return c:IsFaceup() and c:IsRank(3) and c:IsType(TYPE_XYZ) and c:IsType(TYPE_PENDULUM)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 and Duel.GetFlagEffect(tp,id+o)>0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
    	local p=tc:GetSummonPlayer()
    	if tc:IsSummonType(SUMMON_TYPE_RITUAL) and tc:IsType(TYPE_RITUAL) and tc:IsType(TYPE_SPIRIT+TYPE_PENDULUM) then
			Duel.RegisterFlagEffect(p,id+o,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
function s.txcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonType,1,nil,SUMMON_TYPE_PENDULUM)
end
function s.txtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.txop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SendtoExtraP(c,nil,REASON_EFFECT)
end
function s.cfilter(c)
	return ((c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousTypeOnField()&TYPE_SPIRIT~=0)
    	or (c:IsPreviousLocation(LOCATION_HAND) and c:IsType(TYPE_SPIRIT))) and c:IsPreviousLocation(LOCATION_MZONE+LOCATION_HAND)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=eg:FilterCount(s.cfilter,nil)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function s.rlcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local og=e:GetHandler():GetOverlayGroup()
	if chk==0 then return og:GetCount()>0 and e:GetHandler():CheckRemoveOverlayCard(tp,og:GetCount(),REASON_COST) end
	Duel.SendtoGrave(og,REASON_COST)
    local ct=Duel.GetOperatedGroup():GetCount()
    e:SetLabel(ct)
end
function s.rltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsReleasableByEffect,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsReleasableByEffect,tp,LOCATION_MZONE,LOCATION_MZONE,nil)	
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,0,0)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.mzrlfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end    
function s.thfilter(c)
	return c:IsSetCard(0xdf95,0xdf96) and c:IsAbleToHand()
end
function s.rlop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectTarget(tp,Card.IsReleasableByEffect,tp,LOCATION_MZONE,LOCATION_MZONE,1,ct,nil)
    if g:GetCount()>0 then
    	Duel.HintSelection(g)
		if Duel.Release(g,REASON_EFFECT)~=0 then
    		local oc=Duel.GetOperatedGroup():FilterCount(s.mzrlfilter,nil,tp)
        	if oc>0 and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,oc,nil)
        		and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
            	Duel.BreakEffect()
        		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,oc,oc,nil)
				if tg:GetCount()>0 then
					Duel.SendtoHand(tg,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-tp,tg)
                end
			end                
        end
	end
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
	return not c:IsType(TYPE_PENDULUM)
end
function s.rlfilter(c)
	return (c:IsPreviousLocation(LOCATION_MZONE) and bit.band(c:GetPreviousTypeOnField(),TYPE_RITUAL+TYPE_SPIRIT)==TYPE_RITUAL+TYPE_SPIRIT)
    	or (c:IsType(TYPE_RITUAL) and c:IsType(TYPE_SPIRIT))
end
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.rlfilter,1,nil) and e:GetHandler():IsFaceup()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function s.SpiritReturnReg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    if not c:IsSummonType(SUMMON_TYPE_XYZ) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_EVENT+0xd7e0000+RESET_PHASE+PHASE_END)
	e1:SetTarget(s.SpiritReturnTargetForced)
	e1:SetOperation(s.SpiritReturnOperation)
	c:RegisterEffect(e1)
end
function s.SpiritReturnTargetForced(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.SpiritReturnOperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoExtraP(c,nil,REASON_EFFECT)
	end
end