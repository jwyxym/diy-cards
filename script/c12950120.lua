--[[
本lua的作者为藜奴儿，如果测试出bug请联系QQ：1502939196

未经允许不支持任何人的任何形式的修改，源数。如有需要请联系作者，而不是私自找人代为修改。
本人对于本lua的任何bug修改、源数和适配后来卡片均为免费，并且追诉期无限。

但是如果使用者私自修改了lua，不论是bug修复还是源数效果，本人对此lua都不会再提供任何形式的支持。
一旦发现任何其他人对本lua进行了任何形式的修改，本人首先自愿放弃此lua除必要署名权以外的所有权利，
同时再也会不承担对此lua的任何维护与后续适配，包括但不限于任何形式的bug修复、效果源数。

如果您想要修改此lua，可以先联系本人，本人会在第一时间进行回复。
并且我承诺，若本人在2天内没有回复您，上述注意事项可作废，您可以直接修改此lua，而后续debug与适配仍然由我来进行。

如果您对本lua有任何疑问，请联系本人，本人会在第一时间进行回复。
如果您对本lua有任何建议，请联系本人，本人会在第一时间进行处理。
]]

--刻界骑士-半人马座
local s,id,o=GetID()
function s.initial_effect(c)
	--仪式召唤限制
	c:EnableReviveLimit()
	--特殊召唤条件
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	--①：根据公开手卡数量回收"刻界"卡
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)

	--②：攻击力上升
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)

	--pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
	--double battle damage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetCondition(s.damcon)
	e3:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e3)
end
function s.filter(c)
	return c:IsSetCard(0x346a) and c:IsAbleToHand() and c:IsAbleToDeck()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local public_count=Duel.GetMatchingGroupCount(Card.IsPublic,tp,LOCATION_HAND,0,nil)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc) and chkc:IsControler(tp)end
	if chk==0 then
		return public_count>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil)
	end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil)
	local ct=math.min(public_count,#g)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local sg=g:Select(tp,1,ct,nil)
	e:SetLabelObject(sg)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,ct-1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetsRelateToChain()
	if #g==0 then return end

	local tc=g:Select(tp,1,1,nil):GetFirst()
	if tc then
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,tc)
			g:RemoveCard(tc)
			if #g>0 then
				Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
			--选择是否持续公开
			if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_PUBLIC)
				e1:SetDescription(66)
				e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
				tc:RegisterEffect(e1)
			end
		end
	end
end
function s.splimit(e,se,sp,st)
	return st&SUMMON_TYPE_RITUAL==SUMMON_TYPE_RITUAL or (se and se:GetHandler():IsSetCard(0x346a))
end
function s.atkfilter(c)
	return c:IsPublic() and c:IsSetCard(0x346a) and c:IsType(TYPE_MONSTER) and c:GetTextAttack()>0
end
function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(s.atkfilter,c:GetControler(),LOCATION_HAND,0,nil)
	local sum=g:GetSum(Card.GetTextAttack)
	return math.floor(sum/2)
end
function s.damcon(e)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and not bc:IsAttribute(ATTRIBUTE_LIGHT)
end

--aux.Stringid对应提示文本:
--aux.Stringid(id,0):公开手卡并防止连锁
--aux.Stringid(id,1):替换效果
