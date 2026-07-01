--重绘五色之路
function c38030115.initial_effect(c)
	c:SetUniqueOnField(1,0,38030115)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--[[--counter
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38030115,1))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,38030115)
	e1:SetCost(c38030115.ctcost)
	e1:SetTarget(c38030115.cttg)
	e1:SetOperation(c38030115.ctop)
	c:RegisterEffect(e1)]]
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38030115,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(c38030115.thcost)
	e2:SetTarget(c38030115.thtg)
	e2:SetOperation(c38030115.thop)
	c:RegisterEffect(e2)
end
function c38030115.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000,true) end
	local lp=Duel.GetLP(tp)
	local t={}
	local f=math.floor((lp)/1000)
	local l=1
	while l<=f and l<=5 do
		t[l]=l*1000
		l=l+1
	end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(38030115,1))
	local announce=Duel.AnnounceNumber(tp,table.unpack(t))
	e:SetLabel(announce)
	Duel.PayLPCost(tp,announce,true)
end
function c38030115.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	local ct=math.floor(e:GetLabel()/1000)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,ct,0,0x1)
end
function c38030115.ctop(e,tp,eg,ep,ev,re,r,rp)
	local ct=math.floor(e:GetLabel()/1000)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1,ct)
	end
end
function c38030115.costfilter(c,tp)
	return c:IsSetCard(0x614) and c:GetLevel()>0 and Duel.IsExistingMatchingCard(c38030115.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetLevel(),c:GetRace(),c:GetAttribute())
end
function c38030115.thfilter(c,lv,race,attr)
	return c:IsLevel(lv) and c:IsRace(race) and c:IsAttribute(attr)
		and c:IsSetCard(0x614) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function c38030115.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c38030115.costfilter,1,nil,tp) and Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
	local tc=Duel.SelectReleaseGroup(tp,c38030115.costfilter,1,1,nil,tp):GetFirst()
	e:SetLabel(tc:GetLevel(),tc:GetRace(),tc:GetAttribute())
	Duel.Release(tc,REASON_COST)
end
function c38030115.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c38030115.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,c38030115.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel()):GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
		Duel.ConfirmCards(1-tp,tc)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_TO_HAND)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c38030115.thlimit)
		e1:SetLabel(e:GetLabel())
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetTargetRange(1,0)
	e0:SetTarget(c38030115.splimit)
	e0:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e0,tp)
end
function c38030115.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsRace(RACE_SPELLCASTER+RACE_FAIRY+RACE_FIEND)
end
function c38030115.thlimit(e,c,tp,re)
	local lv,race,attr=e:GetLabel()
	return (c:IsLevel(lv) or c:IsRace(race) or c:IsAttribute(attr)) and re and re:GetHandler():IsCode(38030115)
end
