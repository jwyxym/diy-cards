--黏糊糊的狐娘
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcMix(c,true,true,s.matfilter1,s.matfilter2,s.matfilter3)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.mtcon)
	e1:SetOperation(s.mtop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	
end
function s.matfilter1(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
end
function s.matfilter2(c)
	return c:IsRace(RACE_AQUA)
end
function s.matfilter3(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) or c:IsRace(RACE_AQUA)
end
function s.valcheck(e,c)
	local tp=e:GetHandler():GetControler()
	local ct1=c:GetMaterial():FilterCount(s.racefilter,nil)
	local ct2=c:GetMaterial():FilterCount(Card.IsRace,nil,RACE_AQUA)
	local ct3=c:GetMaterial():FilterCount(s.racefilter2,nil,tp)
	e:GetLabelObject():SetLabel(ct1,ct2,ct3)
end
function s.racefilter(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
end
function s.racefilter2(c,tp)
	return c:GetOwner()~=tp
end
function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct1,ct2,ct3=e:GetLabel()
	if ct1>0 then
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,ct1,nil)
		if #g>0 then
			local tc=g:GetFirst()
			while tc do
				tc:AddCounter(0x1579,1)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_LEVEL)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetCondition(s.lvcon)
				e1:SetValue(3)
				tc:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_CHANGE_RACE)
				e2:SetValue(RACE_AQUA)
				tc:RegisterEffect(e2)
				local e3=e1:Clone()
				e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
				e3:SetValue(ATTRIBUTE_WATER)
				tc:RegisterEffect(e3)
				tc=g:GetNext()
			end
		end
	end

	if ct2>0 then
		local e5=Effect.CreateEffect(c)
		e5:SetDescription(aux.Stringid(id,2))
		e5:SetType(EFFECT_TYPE_QUICK_O)
		e5:SetCode(EVENT_FREE_CHAIN)
		e5:SetRange(LOCATION_MZONE)
		e5:SetHintTiming(0,TIMING_MAIN_END+TIMINGS_CHECK_MONSTER)
		e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e5:SetCountLimit(1)
		e5:SetTarget(s.ovltg)
		e5:SetOperation(s.ovlop)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e5)
	end
	if ct2>1 then
		local e4=Effect.CreateEffect(c)
		e4:SetDescription(aux.Stringid(id,1))
		e4:SetType(EFFECT_TYPE_QUICK_O)
		e4:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
		e4:SetRange(LOCATION_MZONE)
		e4:SetCountLimit(1)
		e4:SetCondition(s.equipcon1)
		e4:SetTarget(s.equiptg)
		e4:SetOperation(s.equipop)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e4)
	end

	if ct3>1 then
		local e6=Effect.CreateEffect(c)
		e6:SetDescription(aux.Stringid(id,0))
		e6:SetCategory(CATEGORY_DISABLE)
		e6:SetType(EFFECT_TYPE_QUICK_O)
		e6:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e6:SetCode(EVENT_CHAINING)
		e6:SetRange(LOCATION_MZONE)
		e6:SetCountLimit(1)
		e6:SetCondition(s.discon)
		e6:SetTarget(s.distg)
		e6:SetOperation(s.disop)
		e6:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e6)
	end
end

function s.lvcon(e)
	return e:GetHandler():GetCounter(0x1579)>0 and e:GetHandler():GetLevel()>0
end

function s.ovfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_AQUA) and c:IsType(TYPE_XYZ)
end
function s.ovltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.ovfilter(chkc) end
	if chk==0 then 
		return Duel.IsExistingTarget(s.ovfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_GRAVE,1,nil,TYPE_MONSTER)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.ovfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.ovlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,0,LOCATION_GRAVE,1,1,nil,TYPE_MONSTER)
	local og=g:GetFirst()
	if not og then return end
	local mg=Group.FromCards(c,og)
	Duel.Overlay(tc,mg)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsLocation(LOCATION_MZONE)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	if Duel.NegateEffect(ev) and tc:IsRelateToEffect(re) and tc:IsCanBeXyzMaterial(nil) then
		if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			local g=Duel.SelectMatchingCard(tp,s.ovfilter,tp,LOCATION_MZONE,0,1,1,nil)
			if #g>0 then Duel.Overlay(g:GetFirst(),tc) end
		end
	end
end
function s.equipcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler()==Duel.GetAttackTarget() or e:GetHandler()==Duel.GetAttacker()
end
function s.equiptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
function s.equipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.Equip(tp,tc,c,true)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetValue(true)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	if Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=g:Select(tp,1,1,nil)
		Duel.XyzSummon(tp,tg:GetFirst(),nil)
		end
	end
end
function s.xyzfilter(c)
	return c:IsXyzSummonable(nil)
end