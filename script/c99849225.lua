-- 鬼八仙·鬼仙转化
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,99849227)  

	-- ① 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.operation1)
	c:RegisterEffect(e1)

	-- ② 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100000)
	e2:SetCondition(s.cond2)
	e2:SetCost(s.cost2)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)
end

-- ========== ① =========

function s.special_filter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_SPECIAL)
		and (c:IsSummonLocation(LOCATION_DECK) or c:IsSummonLocation(LOCATION_GRAVE))
end


function s.recycle_filter(c)
	return aux.IsCodeListed(c,99849227) and c:IsAbleToHand()
end

function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then

		return true
	end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_GRAVE)
end

function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()


	local race_eff=Effect.CreateEffect(c)
	race_eff:SetType(EFFECT_TYPE_FIELD)
	race_eff:SetCode(EFFECT_CHANGE_RACE)
	race_eff:SetTargetRange(0, LOCATION_MZONE)  
	race_eff:SetTarget(function(e, tc)
		return s.special_filter(tc)
	end)
	race_eff:SetValue(RACE_ZOMBIE)
   
	race_eff:SetReset(RESET_PHASE+PHASE_END, 2)
	Duel.RegisterEffect(race_eff, tp)

 
	local recycle_filter_exclude_self = function(card)
		return s.recycle_filter(card) and card ~= c
	end
	if Duel.IsExistingMatchingCard(recycle_filter_exclude_self, tp, LOCATION_GRAVE, 0, 1, 1)
		and Duel.SelectYesNo(tp, aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
		local rg=Duel.SelectMatchingCard(tp, recycle_filter_exclude_self, tp, LOCATION_GRAVE, 0, 1, 1, nil)
		if #rg>0 then
			Duel.SendtoHand(rg, nil, REASON_EFFECT)
			Duel.ConfirmCards(1-tp, rg)
		end
	end
end

-- ========== ② ==========
function s.cond2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end

function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
	Duel.Remove(e:GetHandler(), POS_FACEUP, REASON_COST)
end

function s.operation2(e,tp,eg,ep,ev,re,r,rp)
  
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return aux.IsCodeListed(c,99849227) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1, tp)
end