--哥布林召唤师 伊希利恩
--卡密ID: 45205510
--字段代码: 0xAC

local s,id=GetID()

function s.initial_effect(c)
	--连接召唤限制
	c:EnableReviveLimit()
	--连接素材：哥布林怪兽2只以上
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(s.lmatfilter),2,99)
	
	--①效果：自己的「哥布林」陷阱卡也能从手卡发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetTarget(s.tgfilter)
	c:RegisterEffect(e1)
	
	--②效果：除外手卡·墓地1只哥布林，从卡组检索1只哥布林，然后自肃（直到下个自己的结束阶段）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	
	--自肃：直到下个自己的结束阶段，只能特殊召唤哥布林怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
	c:RegisterEffect(e3)
	
	--③效果：这张卡被除外的场合，从卡组检索1张哥布林魔陷，然后返回额外卡组
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_REMOVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id+200)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end

--连接素材条件
function s.lmatfilter(c)
	return c:IsSetCard(0xAC) and c:IsType(TYPE_MONSTER)
end

--①效果：可以手卡发动的陷阱卡
function s.tgfilter(e,c)
	return c:IsSetCard(0xAC) and c:IsType(TYPE_TRAP)
end

--②效果Cost：除外手卡·墓地1只哥布林怪兽
function s.costfilter(c)
	return c:IsSetCard(0xAC) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

--②效果：从卡组检索1只哥布林怪兽
function s.thfilter(c)
	return c:IsSetCard(0xAC) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--②效果自肃：只能特殊召唤哥布林怪兽
function s.splimit(e,c)
	return not c:IsSetCard(0xAC)
end

--③效果：从卡组检索哥布林魔法·陷阱卡
function s.spfilter2(c)
	return c:IsSetCard(0xAC) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	-- 返回额外卡组
	if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_REMOVED) then
		Duel.SendtoExtraP(c,nil,REASON_EFFECT)
	end
end