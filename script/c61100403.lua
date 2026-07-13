--均色史莱姆-紫史莱姆
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.valcon)
	c:RegisterEffect(e1)
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1a:SetValue(1)
	c:RegisterEffect(e1a)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DOUBLE_XMATERIAL)
	e3:SetRange(LOCATION_MZONE+LOCATION_SZONE)
	e3:SetTarget(s.sxyzfilter)
	e3:SetValue(id)
	e3:SetCountLimit(1,id+10000)
	c:RegisterEffect(e3)
	
end
function s.sxyzfilter(e,c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end
function s.valcon(e,re,r,rp)
	if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else
		return 0
	end
end
function s.spfilter2(c,e,tp)
	return c:IsType(TYPE_MONSTER)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local b1=Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_MZONE,0,1,nil)
	local b2=Duel.IsExistingTarget(s.spfilter2,tp,0,LOCATION_MZONE,1,nil) and c:IsHasEffect(61100441) and Duel.GetFlagEffect(tp,61100441)==0
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (b1 or b2)
	end
		if b1 and not b2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_MZONE,0,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
		elseif b2 and not b1 then
		local g=Duel.SelectTarget(tp,s.spfilter2,tp,0,LOCATION_MZONE,1,1,nil)
		Duel.RegisterFlagEffect(tp,61100441,RESET_PHASE+PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
		elseif b1 and b2 then
		local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(61100441,0)},{b2,aux.Stringid(61100441,1)})
		if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_MZONE,0,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
		elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=Duel.SelectTarget(tp,s.spfilter2,tp,0,LOCATION_MZONE,1,1,nil)
		Duel.RegisterFlagEffect(tp,61100441,RESET_PHASE+PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	if not tc:IsRelateToEffect(e) then return end
	if not Duel.Equip(tp,tc,c) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(s.eqlimit)
	e1:SetLabelObject(c)
	tc:RegisterEffect(e1)
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function s.costfilter(c)
	return bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0
end
function s.tg3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(s.costfilter,nil)
	if chk==0 then return #g>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOHAND)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	local p=tc:GetOwner()
	e:SetLabel(p)
	Duel.SendtoHand(tc,p,REASON_COST)
end

function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p=e:GetLabel()
	local g=Duel.GetFieldGroup(p,LOCATION_HAND,0)
	if #g==0 then return end
	local tc=g:RandomSelect(tp,1):GetFirst()
	Duel.ConfirmCards(1-p,tc)
	if tc:IsType(TYPE_MONSTER) then
		if c:IsRelateToEffect(e) then
			Duel.Equip(tp,tc,c)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		e1:SetLabelObject(c)
		tc:RegisterEffect(e1)
		end
	elseif tc:IsType(TYPE_SPELL+TYPE_TRAP) then
		local xg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_XYZ)
		if #xg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
			local xc=xg:Select(tp,1,1,nil):GetFirst()
			if xc then
				Duel.Overlay(xc,tc)
			end
		end
	end
	Duel.ShuffleHand(p)
end