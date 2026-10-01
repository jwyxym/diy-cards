-- 鬼八仙·各显神通 (ID:99849226)
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,99849227)  

  
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.operation1)
	c:RegisterEffect(e1)

 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+10000)
	e2:SetCost(s.cost2)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)
end

-- ========== ① ==========

function s.send_filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and (c:IsCode(99849227) or aux.IsCodeListed(c,99849227))
end


function s.gy_count(tp)
	return Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,99849227)
end


function s.draw_check(e,tp)
	return s.gy_count(tp)>=1 and Duel.IsPlayerCanDraw(tp,1)
end


function s.ac_check(e,tp)
	return s.gy_count(tp)>=2
end


function s.dmg_check(e,tp)
	return s.gy_count(tp)>=3
end

function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.send_filter, tp, LOCATION_DECK, 0, 1, nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	if s.draw_check(e,tp) then
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end

function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp, s.send_filter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g==0 then return end
	Duel.SendtoGrave(g, REASON_EFFECT)

	-- ●1张
	if s.draw_check(e,tp) then
		Duel.Draw(tp, 1, REASON_EFFECT)
	end

	-- ●2张
	if s.ac_check(e,tp) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(0,1)
		e1:SetValue(s.aclimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1, tp)
	end

	-- ●3张：

	if s.dmg_check(e,tp) then
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e2:SetDescription(aux.Stringid(id,3))
		e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e2:SetTargetRange(0,1)
		e2:SetCondition(s.damcon)
		e2:SetValue(DOUBLE_DAMAGE)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2, tp)
	end
end

--●2张：

function s.aclimit(e, re, tp)
	local ph=Duel.GetCurrentPhase()
	if ph<PHASE_BATTLE_START or ph>PHASE_BATTLE_END then return false end
	local rc=re:GetHandler()
	return rc:IsLocation(LOCATION_ONFIELD) and rc:IsType(TYPE_SPELL+TYPE_TRAP)
end

-- ●3张

function s.damcon(e)
	local tp=e:GetHandlerPlayer()
	local a=Duel.GetAttacker()
	return a and a:IsControler(tp) and a:IsFaceup() and a:IsRace(RACE_ZOMBIE)
end

-- ========== ② ==========

function s.thfilter2(c)
	return c:IsCode(99849227) and c:IsAbleToHand()
end

function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(), POS_FACEUP, REASON_COST)
end

function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter2),
			tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1, nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.thfilter2),
		tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1, 1, nil)
	if #g>0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1-tp, g)
	end
end