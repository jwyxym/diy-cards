--中秋赠礼
local s,id=GetID()
function s.initial_effect(c)
	--① 对方从卡组把1张卡加入手卡，不能发动，之后对方选1个效果适用
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

--① 目标
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_DECK,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_DECK)
end

--① 处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 对方从卡组把1张卡加入手卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(1-tp,nil,1-tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 then return end
	if Duel.SendtoHand(g,nil,REASON_EFFECT)==0 then return end
	Duel.ConfirmCards(tp,g)
	Duel.ShuffleDeck(1-tp)
	
	-- 加入手卡的卡的卡名不能在这个回合发动
	local tc=g:GetFirst()
	if tc and tc:IsLocation(LOCATION_HAND) then
		local e0=Effect.CreateEffect(e:GetHandler())
		e0:SetType(EFFECT_TYPE_FIELD)
		e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e0:SetCode(EFFECT_CANNOT_ACTIVATE)
		e0:SetTargetRange(1,0)
		e0:SetValue(s.aclimit0)
		e0:SetLabel(tc:GetCode())
		e0:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e0,tp)
	end
	
	-- 对方选1个效果适用
	local op=Duel.SelectOption(1-tp,
		aux.Stringid(id,1),
		aux.Stringid(id,2),
		aux.Stringid(id,3),
		aux.Stringid(id,4),
		aux.Stringid(id,5))+1
	
	if op==1 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,1-tp)
	elseif op==2 then
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_TO_HAND)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e2:SetTargetRange(1,0)
		e2:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_DECK))
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,1-tp)
	elseif op==3 then
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_ACTIVATE)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e3:SetTargetRange(1,0)
		e3:SetValue(s.aclimit3)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,1-tp)
	elseif op==4 then
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e4:SetTargetRange(1,0)
		e4:SetTarget(s.splimit)
		e4:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e4,1-tp)
	elseif op==5 then
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end

-- 加入手卡的卡的卡名不能发动
function s.aclimit0(e,re,tp)
	local c=re:GetHandler()
	return c:IsCode(e:GetLabel()) or c:GetOriginalCode()==e:GetLabel()
end

-- 选项1
function s.aclimit1(e,re,rp)
	if rp~=1-e:GetHandlerPlayer() then return false end
	if not re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) then return false end
	local chain=Duel.GetCurrentChain()
	if chain<2 then return false end
	local te=Duel.GetChainInfo(chain-1,CHAININFO_TRIGGERING_EFFECT)
	return te and te:GetHandlerPlayer()==e:GetHandlerPlayer()
end

-- 选项3
function s.aclimit3(e,re,rp)
	return rp==1-e:GetHandlerPlayer() 
		and re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
		and re:GetHandler():IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
end

-- 选项4
function s.splimit(e,c)
	return c:IsLocation(LOCATION_HAND+LOCATION_DECK) and c:IsType(TYPE_MONSTER)
end

return s