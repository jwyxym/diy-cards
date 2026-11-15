--神葬零娘 零之葬送
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,94380860,20785975)

	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_DAMAGE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.filter103(c)
	return c:IsFaceup()
		and c:IsType(TYPE_XYZ)
		and (c:IsCode(94380860) or c:IsCode(20785975) or aux.IsCodeListed(c,94380860))
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(1-tp)
			and chkc:IsLocation(LOCATION_MZONE)
			and chkc:IsFaceup()
	end
	if chk==0 then
		return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end

	local total_damage = 0


	local atk1 = tc:GetAttack()
	local actual_down1 = math.min(atk1, 1000) 
	if atk1 > 0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-actual_down1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		total_damage = total_damage + actual_down1
	else
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end


	Duel.Draw(tp, 1, REASON_EFFECT)


	local has_103 = Duel.IsExistingMatchingCard(s.filter103, tp, LOCATION_MZONE, 0, 1, nil)
	if has_103 then
		local g2 = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil)
		if #g2 > 0 and Duel.SelectYesNo(tp, aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
			local sc = g2:Select(tp, 1, 1, nil):GetFirst()
			if sc then
		
				local atk2 = sc:GetAttack()
				local actual_down2 = math.min(atk2, 1000)
				if atk2 > 0 then
					local e2=Effect.CreateEffect(c)
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetCode(EFFECT_UPDATE_ATTACK)
					e2:SetValue(-actual_down2)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD)
					sc:RegisterEffect(e2)
					total_damage = total_damage + actual_down2
				else
					local e2=Effect.CreateEffect(c)
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetCode(EFFECT_UPDATE_ATTACK)
					e2:SetValue(0)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD)
					sc:RegisterEffect(e2)
				end
	
				local def2 = sc:GetDefense()
				local actual_down_def = math.min(def2, 1000)
				if def2 > 0 then
					local e3=Effect.CreateEffect(c)
					e3:SetType(EFFECT_TYPE_SINGLE)
					e3:SetCode(EFFECT_UPDATE_DEFENSE)
					e3:SetValue(-actual_down_def)
					e3:SetReset(RESET_EVENT+RESETS_STANDARD)
					sc:RegisterEffect(e3)
				else
					local e3=Effect.CreateEffect(c)
					e3:SetType(EFFECT_TYPE_SINGLE)
					e3:SetCode(EFFECT_UPDATE_DEFENSE)
					e3:SetValue(0)
					e3:SetReset(RESET_EVENT+RESETS_STANDARD)
					sc:RegisterEffect(e3)
				end
			end
		end
	end


	if total_damage > 0 then
		Duel.BreakEffect()
		Duel.Damage(1-tp, total_damage, REASON_EFFECT)
	end
end