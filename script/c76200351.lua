--环抱着你的希望之星
local this,id,ofs=GetID()
function this.initial_effect(c)
	c:EnableCounterPermit(0x1)
	--Active
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(this.activate)
	c:RegisterEffect(e1)
	--Add Counter
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(this.counterop)
	c:RegisterEffect(e3)
	--destroy replace
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTarget(this.reptg)
	e4:SetValue(this.repval)
	e4:SetOperation(this.repop)
	c:RegisterEffect(e4)
end
function this.filter(c)
	return c:IsLevelBelow(4) and c:IsType(TYPE_PENDULUM) and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand()
end
function this.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(this.filter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function this.counterop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
function this.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function this.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(this.repfilter,1,nil,tp)
		and c:IsCanRemoveCounter(tp,0x1,3,REASON_EFFECT) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function this.repval(e,c)
	return this.repfilter(c,e:GetHandlerPlayer())
end
function this.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RemoveCounter(tp,1,0,0x1,3,REASON_EFFECT)
end
