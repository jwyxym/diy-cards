--李代桃僵
local s,id=GetID()
function s.initial_effect(c)
	--卡片发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--① 这张卡以外的自己场上的卡被破坏的场合，作为代替把场上的这张卡送去墓地。
	--   自己场上有植物族怪兽的场合，再抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTarget(s.desreptg)
	e1:SetValue(s.desrepval)
	e1:SetOperation(s.desrepop)
	c:RegisterEffect(e1)

	--② 把这张卡从墓地除外才能发动。从自己墓地·除外状态把1只植物族怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

-- ① 代替破坏过滤：这张卡以外的自己场上的卡被效果破坏
function s.repfilter(c,tp,ec)
	return c:IsControler(tp) and c:IsOnField()
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		and c~=ec
end

-- ① 代替破坏条件
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp,c)
		and c:IsAbleToGrave() and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED) end
	return Duel.SelectEffectYesNo(tp,c,96)
end

-- ① 代替破坏判定
function s.desrepval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer(),e:GetHandler())
end

-- ① 代替处理：把这张卡送墓，场上有植物族则抽1
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_CARD,0,id)
	if Duel.SendtoGrave(c,REASON_EFFECT+REASON_REPLACE)>0 then
		if Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_MZONE,0,1,nil) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end

-- 植物族过滤
function s.plfilter(c)
	return c:IsRace(RACE_PLANT)
end

-- ② 回收过滤：植物族怪兽
function s.thfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToHand()
end

-- ② target
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

-- ② operation
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

return s
