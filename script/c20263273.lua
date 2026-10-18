-- 王家魔族的现场演唱竞技场 (ID: 20263273)
local s,id,o=GetID()
function s.initial_effect(c)
	-- ①：作为这张卡发动的效果处理时，可以从卡组把1张「王家魔族」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id) -- 效果①独立 HOPT
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)

	-- ②：只要这张卡在场地区域存在，自己场上的「王家魔族」怪兽在自己回合内不受对方的怪兽的效果影响...
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.immcon)
	e2:SetTarget(s.tgtg)
	e2:SetValue(s.immval)
	c:RegisterEffect(e2)

	-- ②：...向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_PIERCE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.tgtg)
	c:RegisterEffect(e3)
end

-- ==================== 效果 ① 相关处理 ====================
function s.thfilter(c)
	return c:IsSetCard(0x321) and c:IsAbleToHand()
end

function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 严格使用原生标准的 SetOperationInfo
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 and Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 and sg:GetFirst():IsLocation(LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end

-- ==================== 效果 ② 相关处理 ====================
function s.immcon(e)
	-- 仅在自己回合内生效
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end

function s.tgtg(e,c)
	return c:IsSetCard(0x321)
end

function s.immval(e,te)
	-- 不受对方怪兽的效果影响
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end