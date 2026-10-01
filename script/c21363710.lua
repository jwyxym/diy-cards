--随风远去的追随 上衫谦信
function c21363710.initial_effect(c)
	aux.AddCodeList(c,21363700)
	c:SetSPSummonOnce(21363710) 
	--spsummon proc
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA) 
	e1:SetCondition(c21363710.espcon)
	e1:SetTarget(c21363710.esptg)
	e1:SetOperation(c21363710.espop)
	c:RegisterEffect(e1)  
	--set
	local e1=Effect.CreateEffect(c) 
	e1:SetType(EFFECT_TYPE_IGNITION) 
	e1:SetRange(LOCATION_MZONE) 
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,21363710)
	e1:SetTarget(c21363710.settg)
	e1:SetOperation(c21363710.setop)
	c:RegisterEffect(e1) 
	--atk 
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCountLimit(1,21363711)
	e2:SetCondition(c21363710.atkcon) 
	e2:SetCost(c21363710.atkcost)
	e2:SetTarget(c21363710.atktg)
	e2:SetOperation(c21363710.atkop)
	c:RegisterEffect(e2)
end
function c21363710.matfil(c)  
	local b1=c:IsLevel(4) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_WARRIOR)
	local b2=c:IsCode(21363700)
	return c:IsFaceup() and c:IsAbleToDeckAsCost() and (b1 or b2)
end 
function c21363710.matfil1(c) 
	return c:IsLevel(4) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_WARRIOR) 
end 
function c21363710.matfil2(c) 
	return c:IsCode(21363700)
end 
function c21363710.matgck(g,e,tp) 
	return Duel.GetLocationCountFromEx(tp,tp,g,e:GetHandler())>0 
	   and g:FilterCount(c21363710.matfil1,nil)>=1 
	   and g:FilterCount(c21363710.matfil2,nil)>=1 
end 
function c21363710.espcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler() 
	local g=Duel.GetMatchingGroup(c21363710.matfil,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	return g:CheckSubGroup(c21363710.matgck,2,2,e,tp)
end
function c21363710.esptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(c21363710.matfil,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:SelectSubGroup(tp,c21363710.matgck,true,2,2,e,tp)
	if sg:GetCount()>0 then 
		sg:KeepAlive()
		e:SetLabelObject(sg) 
		return true
	else return false end
end
function c21363710.espop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.SendtoDeck(g,nil,2,REASON_SPSUMMON)
end
function c21363710.setfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable()
end
function c21363710.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) 
	if chkc then return c21363710.setfilter(chkc) and chkc:IsLocation(LOCATION_GRAVE) end 
	if chk==0 then return Duel.IsExistingTarget(c21363710.setfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end  
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET) 
	local g=Duel.SelectTarget(tp,c21363710.setfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
end
function c21363710.setop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and Duel.SSet(tp,tc)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1)	 
	end
end
function c21363710.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker()==e:GetHandler()
end
function c21363710.ctfil(c) 
	return c:IsAbleToDeckAsCost() and c:IsCode(21363700) 
end 
function c21363710.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21363710.ctfil,tp,LOCATION_GRAVE,0,1,nil) end 
	local g=Duel.SelectMatchingCard(tp,c21363710.ctfil,tp,LOCATION_GRAVE,0,1,1,nil) 
	Duel.SendtoDeck(g,nil,2,REASON_COST) 
end 
function c21363710.atktg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local x=Duel.GetMatchingGroupCount(function(c) return c:IsFaceup() and c:IsType(TYPE_TRAP) end,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	if chk==0 then return x>0 end 
end
function c21363710.atkop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	local x=Duel.GetMatchingGroupCount(function(c) return c:IsFaceup() and c:IsType(TYPE_TRAP) end,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil) 
	if x>0 and c:IsRelateToEffect(e) and c:IsFaceup() then 
		local e1=Effect.CreateEffect(c) 
		e1:SetType(EFFECT_TYPE_SINGLE) 
		e1:SetCode(EFFECT_UPDATE_ATTACK) 
		e1:SetValue(x*500) 
		e1:SetRange(LOCATION_MZONE) 
		e1:SetReset(RESET_EVENT+RESETS_STANDARD) 
		c:RegisterEffect(e1) 
	end  
end

